# Antigravity / AI Agent Guidelines

This file (`AGENTS.md`) contains the core rules and guidelines for any AI coding assistant or agent interacting with the Board Game Café repository.

## 1. AI Transparency & Logging (CRITICAL)
- **MANDATORY RULE:** Every single AI prompt or significant interaction used to generate, debug, or modify code in this project MUST be logged in `docs/AI_USAGE.md`. 
- Whenever you complete a task for the user, you must append the user's prompt, what you did, and any issues encountered to the "Prompting Workflow" section of `docs/AI_USAGE.md`.

## 2. Tech Stack & Execution Environment
- **Database:** SQLite3. To reset the DB, run `bash setup.sh` from the repository root.
- **Backend:** Node.js + Express 4.
- **Frontend:** EJS Templates with minimal Bootstrap styling.
- **Running the App:** The application is located inside the `app/` directory! You MUST run `cd app && npm start` (or `node app.js`) to start the server. Do not attempt to run Node from the root directory.

## 3. Workflow Rules
- Always verify your changes before returning to the user. E.g., if you modify the DB schema, run the setup script. If you modify views, start the server (`node app.js` in `app/`) and use `curl` to test the endpoint.
- Keep the directory structure strictly organized: 
  - diagrams in `diagrams/`
  - documentation in `docs/`
  - SQL scripts in `sql/`
  - Web application in `app/`
- Avoid `better-sqlite3` native compilation issues in some environments by continuing to use `sql.js` unless explicitly instructed to migrate by the user. Note that `sql.js` does require application-level Foreign Key (FK) checks prior to DELETE operations.
