const express = require("express");
const path = require("path");
const fs = require("fs");
const initSqlJs = require("sql.js");

const app = express();
const PORT = 3000;

// Database lives at the repository root
const DB_PATH = path.join(__dirname, "..", "boardgame_cafe.db");

// ── Middleware ────────────────────────────────────────────────
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));
app.use(express.urlencoded({ extended: true }));

// ── Database helpers ─────────────────────────────────────────
let db;

async function initDB() {
  if (!fs.existsSync(DB_PATH)) {
    console.error(`ERROR: Database not found at ${DB_PATH}`);
    console.error("Run 'bash setup.sh' from the repository root first.");
    process.exit(1);
  }
  const SQL = await initSqlJs();
  const buf = fs.readFileSync(DB_PATH);
  db = new SQL.Database(buf);
  db.run("PRAGMA foreign_keys = ON;");
  console.log(`Database loaded from ${DB_PATH}`);
}

function saveDB() {
  const data = db.export();
  fs.writeFileSync(DB_PATH, Buffer.from(data));
}

function queryAll(sql, params = []) {
  const stmt = db.prepare(sql);
  stmt.bind(params);
  const rows = [];
  while (stmt.step()) rows.push(stmt.getAsObject());
  stmt.free();
  return rows;
}

function queryOne(sql, params = []) {
  const rows = queryAll(sql, params);
  return rows.length > 0 ? rows[0] : null;
}

// ── HOME ─────────────────────────────────────────────────────
app.get("/", (req, res) => {
  const stats = {
    publishers: queryOne("SELECT COUNT(*) AS n FROM Publisher").n,
    games:      queryOne("SELECT COUNT(*) AS n FROM Game").n,
    members:    queryOne("SELECT COUNT(*) AS n FROM Member").n,
    sessions:   queryOne("SELECT COUNT(*) AS n FROM PlaySession").n,
  };
  res.render("index", { stats });
});

// ══════════════════════════════════════════════════════════════
//  PUBLISHER CRUD
// ══════════════════════════════════════════════════════════════

app.get("/publishers", (req, res) => {
  const publishers = queryAll(`
    SELECT p.*, COUNT(g.game_id) AS game_count
    FROM Publisher p LEFT JOIN Game g ON p.publisher_id = g.publisher_id
    GROUP BY p.publisher_id ORDER BY p.name`);
  res.render("publishers/index", { publishers, message: req.query.message || null });
});

app.get("/publishers/new", (req, res) => {
  res.render("publishers/form", { publisher: null, error: null });
});

app.post("/publishers", (req, res) => {
  const { name, country, website, founded_year } = req.body;
  try {
    db.run(
      "INSERT INTO Publisher (name, country, website, founded_year) VALUES (?, ?, ?, ?)",
      [name, country, website || null, founded_year ? Number(founded_year) : null]
    );
    saveDB();
    res.redirect("/publishers?message=Publisher created successfully");
  } catch (err) {
    res.render("publishers/form", { publisher: req.body, error: err.message });
  }
});

app.get("/publishers/:id/edit", (req, res) => {
  const publisher = queryOne(
    "SELECT * FROM Publisher WHERE publisher_id = ?", [Number(req.params.id)]
  );
  if (!publisher) return res.status(404).send("Publisher not found");
  res.render("publishers/form", { publisher, error: null });
});

app.post("/publishers/:id", (req, res) => {
  const { name, country, website, founded_year } = req.body;
  try {
    db.run(
      `UPDATE Publisher SET name=?, country=?, website=?, founded_year=?
       WHERE publisher_id=?`,
      [name, country, website || null, founded_year ? Number(founded_year) : null,
       Number(req.params.id)]
    );
    saveDB();
    res.redirect("/publishers?message=Publisher updated successfully");
  } catch (err) {
    res.render("publishers/form", {
      publisher: { ...req.body, publisher_id: req.params.id }, error: err.message
    });
  }
});

app.post("/publishers/:id/delete", (req, res) => {
  const id = Number(req.params.id);
  // Application-level FK check (sql.js WASM doesn't enforce FK reliably)
  const gameCount = queryOne(
    "SELECT COUNT(*) AS n FROM Game WHERE publisher_id = ?", [id]
  );
  if (gameCount && gameCount.n > 0) {
    return res.redirect(
      "/publishers?message=" +
      encodeURIComponent(`Cannot delete: publisher still has ${gameCount.n} game(s). Remove them first.`)
    );
  }
  try {
    db.run("DELETE FROM Publisher WHERE publisher_id = ?", [id]);
    saveDB();
    res.redirect("/publishers?message=Publisher deleted successfully");
  } catch (err) {
    res.redirect(
      "/publishers?message=" + encodeURIComponent("Cannot delete: " + err.message)
    );
  }
});

// ══════════════════════════════════════════════════════════════
//  GAME CRUD
// ══════════════════════════════════════════════════════════════

app.get("/games", (req, res) => {
  const games = queryAll(`
    SELECT g.*, p.name AS publisher_name
    FROM Game g INNER JOIN Publisher p ON g.publisher_id = p.publisher_id
    ORDER BY g.title`);
  res.render("games/index", { games, message: req.query.message || null });
});

app.get("/games/new", (req, res) => {
  const publishers = queryAll("SELECT publisher_id, name FROM Publisher ORDER BY name");
  res.render("games/form", { game: null, publishers, error: null });
});

app.post("/games", (req, res) => {
  const b = req.body;
  try {
    db.run(
      `INSERT INTO Game (title, min_players, max_players, play_time_minutes,
         complexity_rating, year_published, copies_owned, is_available, publisher_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [b.title, Number(b.min_players), Number(b.max_players),
       b.play_time_minutes ? Number(b.play_time_minutes) : null,
       b.complexity_rating ? Number(b.complexity_rating) : null,
       b.year_published ? Number(b.year_published) : null,
       Number(b.copies_owned) || 1, b.is_available ? 1 : 0,
       Number(b.publisher_id)]
    );
    saveDB();
    res.redirect("/games?message=Game created successfully");
  } catch (err) {
    const publishers = queryAll("SELECT publisher_id, name FROM Publisher ORDER BY name");
    res.render("games/form", { game: b, publishers, error: err.message });
  }
});

app.get("/games/:id/edit", (req, res) => {
  const game = queryOne("SELECT * FROM Game WHERE game_id = ?", [Number(req.params.id)]);
  if (!game) return res.status(404).send("Game not found");
  const publishers = queryAll("SELECT publisher_id, name FROM Publisher ORDER BY name");
  res.render("games/form", { game, publishers, error: null });
});

app.post("/games/:id", (req, res) => {
  const b = req.body;
  try {
    db.run(
      `UPDATE Game SET title=?, min_players=?, max_players=?, play_time_minutes=?,
         complexity_rating=?, year_published=?, copies_owned=?, is_available=?,
         publisher_id=? WHERE game_id=?`,
      [b.title, Number(b.min_players), Number(b.max_players),
       b.play_time_minutes ? Number(b.play_time_minutes) : null,
       b.complexity_rating ? Number(b.complexity_rating) : null,
       b.year_published ? Number(b.year_published) : null,
       Number(b.copies_owned) || 1, b.is_available ? 1 : 0,
       Number(b.publisher_id), Number(req.params.id)]
    );
    saveDB();
    res.redirect("/games?message=Game updated successfully");
  } catch (err) {
    const publishers = queryAll("SELECT publisher_id, name FROM Publisher ORDER BY name");
    res.render("games/form", {
      game: { ...b, game_id: req.params.id }, publishers, error: err.message
    });
  }
});

app.post("/games/:id/delete", (req, res) => {
  const id = Number(req.params.id);
  // Application-level FK check
  const sessionCount = queryOne(
    "SELECT COUNT(*) AS n FROM PlaySession WHERE game_id = ?", [id]
  );
  if (sessionCount && sessionCount.n > 0) {
    return res.redirect(
      "/games?message=" +
      encodeURIComponent(`Cannot delete: game has ${sessionCount.n} play session(s). Remove them first.`)
    );
  }
  try {
    db.run("DELETE FROM Game WHERE game_id = ?", [id]);
    // Also clean up GameCategory entries
    db.run("DELETE FROM GameCategory WHERE game_id = ?", [id]);
    saveDB();
    res.redirect("/games?message=Game deleted successfully");
  } catch (err) {
    res.redirect("/games?message=" + encodeURIComponent("Cannot delete: " + err.message));
  }
});

// ── Start ────────────────────────────────────────────────────
initDB().then(() => {
  app.listen(PORT, () => {
    console.log(`Board Game Cafe running at http://localhost:${PORT}`);
  });
});
