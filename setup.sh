#!/bin/bash
# ============================================================
# setup.sh — Create and populate the Board Game Cafe database
# Run from the repository root: bash setup.sh
# ============================================================

set -e

DB_FILE="boardgame_cafe.db"

echo "==> Removing old database (if any)..."
rm -f "$DB_FILE"

echo "==> Creating tables..."
sqlite3 "$DB_FILE" < sql/create_tables.sql

echo "==> Populating test data..."
sqlite3 "$DB_FILE" < sql/populate_data.sql

echo ""
echo "==> Database created successfully: $DB"
echo ""
echo "    Tables:"
sqlite3 "$DB" ".tables"
echo ""
echo "    Row counts:"
for t in Publisher Category Game GameCategory Member PlaySession SessionPlayer; do
    count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM $t;")
    printf "      %-16s %s rows\n" "$t" "$count"
done

echo ""
echo "==> To run queries:"
echo "    sqlite3 -header -column $DB < sql/queries/query1_three_table_join.sql"
echo ""
echo "==> To start the web app:"
echo "    cd app && npm install && node app.js"
