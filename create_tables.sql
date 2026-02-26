-- ============================================================
-- Board Game Cafe Database
-- DDL: Table Creation Script for SQLite3
-- ============================================================
-- Run with: sqlite3 boardgame_cafe.db < create_tables.sql
-- ============================================================

-- Enable foreign key enforcement (off by default in SQLite)
PRAGMA foreign_keys = ON;

-- Drop tables if they exist (in reverse dependency order)
DROP TABLE IF EXISTS SessionPlayer;
DROP TABLE IF EXISTS PlaySession;
DROP TABLE IF EXISTS GameCategory;
DROP TABLE IF EXISTS Game;
DROP TABLE IF EXISTS Category;
DROP TABLE IF EXISTS Member;
DROP TABLE IF EXISTS Publisher;

-- ============================================================
-- 1. Publisher
-- ============================================================
CREATE TABLE Publisher (
    publisher_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT    NOT NULL,
    country         TEXT    NOT NULL,
    website         TEXT,
    founded_year    INTEGER,
    CHECK (founded_year IS NULL OR (founded_year > 1800 AND founded_year <= 2025))
);

-- ============================================================
-- 2. Category
-- ============================================================
CREATE TABLE Category (
    category_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    name            TEXT    NOT NULL UNIQUE,
    description     TEXT
);

-- ============================================================
-- 3. Game
-- ============================================================
CREATE TABLE Game (
    game_id             INTEGER PRIMARY KEY AUTOINCREMENT,
    title               TEXT    NOT NULL,
    min_players         INTEGER NOT NULL DEFAULT 1,
    max_players         INTEGER NOT NULL DEFAULT 4,
    play_time_minutes   INTEGER,
    complexity_rating   REAL,
    year_published      INTEGER,
    copies_owned        INTEGER NOT NULL DEFAULT 1,
    is_available        INTEGER NOT NULL DEFAULT 1,  -- 0=false, 1=true (SQLite has no BOOLEAN)
    publisher_id        INTEGER NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES Publisher(publisher_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (min_players >= 1),
    CHECK (max_players >= min_players),
    CHECK (complexity_rating IS NULL OR (complexity_rating >= 1.0 AND complexity_rating <= 5.0)),
    CHECK (copies_owned >= 0),
    CHECK (is_available IN (0, 1))
);

-- ============================================================
-- 4. GameCategory (Association: Game M:N Category)
-- ============================================================
CREATE TABLE GameCategory (
    game_id         INTEGER NOT NULL,
    category_id     INTEGER NOT NULL,
    PRIMARY KEY (game_id, category_id),
    FOREIGN KEY (game_id)     REFERENCES Game(game_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ============================================================
-- 5. Member
-- ============================================================
CREATE TABLE Member (
    member_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name      TEXT    NOT NULL,
    last_name       TEXT    NOT NULL,
    email           TEXT    NOT NULL UNIQUE,
    phone           TEXT,
    join_date       TEXT    NOT NULL DEFAULT (DATE('now'))
);

-- ============================================================
-- 6. PlaySession
-- ============================================================
CREATE TABLE PlaySession (
    session_id          INTEGER PRIMARY KEY AUTOINCREMENT,
    game_id             INTEGER NOT NULL,
    session_date        TEXT    NOT NULL DEFAULT (DATETIME('now')),
    duration_minutes    INTEGER,
    table_number        INTEGER,
    FOREIGN KEY (game_id) REFERENCES Game(game_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CHECK (duration_minutes IS NULL OR duration_minutes > 0),
    CHECK (table_number IS NULL OR table_number > 0)
);

-- ============================================================
-- 7. SessionPlayer (Association: PlaySession M:N Member)
-- ============================================================
CREATE TABLE SessionPlayer (
    session_id      INTEGER NOT NULL,
    member_id       INTEGER NOT NULL,
    rating          INTEGER,
    comment         TEXT,
    PRIMARY KEY (session_id, member_id),
    FOREIGN KEY (session_id) REFERENCES PlaySession(session_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (member_id)  REFERENCES Member(member_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (rating IS NULL OR (rating >= 1 AND rating <= 10))
);

-- ============================================================
-- Indexes for common query patterns
-- ============================================================
CREATE INDEX idx_game_publisher    ON Game(publisher_id);
CREATE INDEX idx_game_title        ON Game(title);
CREATE INDEX idx_session_game      ON PlaySession(game_id);
CREATE INDEX idx_session_date      ON PlaySession(session_date);
CREATE INDEX idx_member_email      ON Member(email);
CREATE INDEX idx_sp_member         ON SessionPlayer(member_id);
