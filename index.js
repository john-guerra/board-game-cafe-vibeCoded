const express = require("express");
const path = require("path");
const fs = require("fs");
const { DatabaseSync } = require("node:sqlite");

const app = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ────────────────────────────────────────────────
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));
app.use(express.urlencoded({ extended: true }));

// ── Database helpers ─────────────────────────────────────────
let db;

function initDB() {
  const isProd = process.env.NODE_ENV === "production";
  // In Vercel, the file system restricts writes to /tmp
  const targetDB = isProd ? "/tmp/boardgame_cafe.db" : path.join(__dirname, "boardgame_cafe.db");

  if (isProd && !fs.existsSync(targetDB)) {
    // Copy the bundled read-only template to the writable directory
    fs.copyFileSync(path.join(__dirname, "boardgame_cafe.db"), targetDB);
  } else if (!fs.existsSync(targetDB)) {
    console.error(`ERROR: Database not found at ${targetDB}`);
    console.error("Run 'bash setup.sh' from the repository root first.");
    process.exit(1);
  }

  // node:sqlite operates synchronously
  db = new DatabaseSync(targetDB);
  db.exec("PRAGMA foreign_keys = ON;");
  console.log(`Database loaded from ${targetDB}`);
}

function runQuery(sql, params = []) {
  const stmt = db.prepare(sql);
  return stmt.run(...params);
}

function queryAll(sql, params = []) {
  const stmt = db.prepare(sql);
  return stmt.all(...params);
}

function queryOne(sql, params = []) {
  const stmt = db.prepare(sql);
  const result = stmt.get(...params);
  return result === undefined ? null : result;
}

// ── HOME ─────────────────────────────────────────────────────
app.get("/", (req, res) => {
  if (!db) initDB();
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
  if (!db) initDB();
  const publishers = queryAll(`
    SELECT p.*, COUNT(g.game_id) AS game_count
    FROM Publisher p LEFT JOIN Game g ON p.publisher_id = g.publisher_id
    GROUP BY p.publisher_id ORDER BY p.name`);
  res.render("publishers/index", { publishers, message: req.query.message || null });
});

app.get("/publishers/new", (req, res) => {
  if (!db) initDB();
  res.render("publishers/form", { publisher: null, error: null });
});

app.post("/publishers", (req, res) => {
  if (!db) initDB();
  const { name, country, website, founded_year } = req.body;
  try {
    runQuery(
      "INSERT INTO Publisher (name, country, website, founded_year) VALUES (?, ?, ?, ?)",
      [name, country, website || null, founded_year ? Number(founded_year) : null]
    );
    res.redirect("/publishers?message=Publisher created successfully");
  } catch (err) {
    res.render("publishers/form", { publisher: req.body, error: err.message });
  }
});

app.get("/publishers/:id/edit", (req, res) => {
  if (!db) initDB();
  const publisher = queryOne(
    "SELECT * FROM Publisher WHERE publisher_id = ?", [Number(req.params.id)]
  );
  if (!publisher) return res.status(404).send("Publisher not found");
  res.render("publishers/form", { publisher, error: null });
});

app.post("/publishers/:id", (req, res) => {
  if (!db) initDB();
  const { name, country, website, founded_year } = req.body;
  try {
    runQuery(
      `UPDATE Publisher SET name=?, country=?, website=?, founded_year=?
       WHERE publisher_id=?`,
      [name, country, website || null, founded_year ? Number(founded_year) : null,
       Number(req.params.id)]
    );
    res.redirect("/publishers?message=Publisher updated successfully");
  } catch (err) {
    res.render("publishers/form", {
      publisher: { ...req.body, publisher_id: req.params.id }, error: err.message
    });
  }
});

app.post("/publishers/:id/delete", (req, res) => {
  if (!db) initDB();
  const id = Number(req.params.id);
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
    runQuery("DELETE FROM Publisher WHERE publisher_id = ?", [id]);
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
  if (!db) initDB();
  const games = queryAll(`
    SELECT g.*, p.name AS publisher_name
    FROM Game g INNER JOIN Publisher p ON g.publisher_id = p.publisher_id
    ORDER BY g.title`);
  res.render("games/index", { games, message: req.query.message || null });
});

app.get("/games/new", (req, res) => {
  if (!db) initDB();
  const publishers = queryAll("SELECT publisher_id, name FROM Publisher ORDER BY name");
  res.render("games/form", { game: null, publishers, error: null });
});

app.post("/games", (req, res) => {
  if (!db) initDB();
  const b = req.body;
  try {
    runQuery(
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
    res.redirect("/games?message=Game created successfully");
  } catch (err) {
    const publishers = queryAll("SELECT publisher_id, name FROM Publisher ORDER BY name");
    res.render("games/form", { game: b, publishers, error: err.message });
  }
});

app.get("/games/:id/edit", (req, res) => {
  if (!db) initDB();
  const game = queryOne("SELECT * FROM Game WHERE game_id = ?", [Number(req.params.id)]);
  if (!game) return res.status(404).send("Game not found");
  const publishers = queryAll("SELECT publisher_id, name FROM Publisher ORDER BY name");
  res.render("games/form", { game, publishers, error: null });
});

app.post("/games/:id", (req, res) => {
  if (!db) initDB();
  const b = req.body;
  try {
    runQuery(
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
    res.redirect("/games?message=Game updated successfully");
  } catch (err) {
    const publishers = queryAll("SELECT publisher_id, name FROM Publisher ORDER BY name");
    res.render("games/form", {
      game: { ...b, game_id: req.params.id }, publishers, error: err.message
    });
  }
});

app.post("/games/:id/delete", (req, res) => {
  if (!db) initDB();
  const id = Number(req.params.id);
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
    runQuery("DELETE FROM Game WHERE game_id = ?", [id]);
    runQuery("DELETE FROM GameCategory WHERE game_id = ?", [id]);
    res.redirect("/games?message=Game deleted successfully");
  } catch (err) {
    res.redirect("/games?message=" + encodeURIComponent("Cannot delete: " + err.message));
  }
});

// ── Start ────────────────────────────────────────────────────
if (process.env.NODE_ENV !== "production") {
  initDB();
  app.listen(PORT, () => {
    console.log(`Board Game Cafe running at http://localhost:${PORT}`);
  });
}

// Export for Vercel
module.exports = app;
