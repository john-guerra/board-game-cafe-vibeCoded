# AI Usage Documentation

This document describes how AI was used to complete the Board Game Café Database project. Its purpose is transparency and reproducibility — anyone reading this should be able to understand exactly what the AI did, what it didn't do, and how to replicate or adapt the workflow for their own projects.

---

## 1. Model and Configuration

| Parameter | Value |
|-----------|-------|
| **Model** | Claude Opus 4.6 (Anthropic) |
| **Interface** | claude.ai web chat with computer use (Code Execution and File Creation enabled) |
| **Date** | February 26, 2026 |
| **Environment** | Ubuntu 24 container with bash, Python 3.12, Node.js 22, SQLite 3.45 |
| **Temperature** | Default (not user-configurable in claude.ai) |
| **Context window** | The full conversation including the assignment PDF was maintained in a single chat session |

### Tools Available to the Model

Claude's "computer use" mode provides a sandboxed Linux environment where the model can execute bash commands, create files, install packages, and run programs. This is how all SQL was executed, the Node app was tested, and PDFs were generated. The model also has access to web search, but it was not used for this project.

### What "Computer Use" Means in Practice

The model doesn't just generate text — it writes files to disk, runs them, reads the output, and iterates. For example, when a SQL query had a syntax error, the model saw the SQLite error message and corrected the query. This is meaningfully different from copy-pasting AI output into a terminal yourself, because the feedback loop is automatic.

---

## 2. Prompting Workflow

The project was completed across **4 prompts** in a single conversation. Below is each prompt (paraphrased), what it produced, and what went wrong.

### Prompt 1: Initial Generation

> **User prompt:** [Uploaded the assignment PDF] "Please complete this assignment"

**What the model did:**
- Read the assignment requirements from the uploaded document
- Chose a domain (Board Game Café) without being asked — this was the model's decision
- Generated all deliverables for points 1–7 in sequence:
  - Requirements PDF (via Python `reportlab`)
  - UML Conceptual Model (as SVG, converted to PNG via `cairosvg`)
  - ERD Logical Model (as SVG, converted to PNG)
  - BCNF Schema proof PDF (via `reportlab`)
  - SQL DDL (`create_tables.sql`)
  - Test data (`populate_data.sql`)
  - 5 SQL query files
- Created the SQLite database, ran all scripts, and verified output
- Ran constraint violation tests to prove CHECK/FK/UNIQUE constraints work

**What went wrong:**
- SVG → PNG conversion failed 5 times due to XML entity issues. The SVGs contained HTML entities (`&eacute;`, `«`, `»`, `→`) and double-dashes in XML comments (`<!-- ---text--- -->`) that the XML parser rejected. The model tried several fixes (replacing entities, removing unicode) before finally stripping all XML comments, which resolved it. This took ~6 iterations.
- `sqlite3` was not pre-installed in the container. The model had to `apt-get install` it.

**What the model chose on its own (no human guidance):**
- The entire domain (Board Game Café with publishers, games, categories, members, sessions)
- The entity structure (5 core entities + 2 association tables)
- All attribute names, data types, and constraints
- Test data (real board game titles, realistic ratings)
- The specific query topics (date-night finder, engagement tiers, etc.)

### Prompt 2: Technology Discussion

> **User prompt:** "For implementing the rest of the application, what technologies do you recommend me to use. Think as a professional software developer and make sure you support your claim with evidence. Also consider that I'm learning these skills and I want something that has good job prospects"

This was a discussion prompt, not a generation prompt. The model recommended sticking with the prescribed Node + Express stack for the assignment, then discussed career-oriented technology choices with evidence from the Stack Overflow Developer Survey and State of JS survey.

### Prompt 3: Build the Node App

> **User prompt:** "yes" (in response to "Want me to build the Node+Express+EJS app for point 8?")

**What the model did:**
- Created a Node + Express + EJS application with full CRUD for Publisher and Game
- Set up proper package.json, views with partials, forms, list pages, and a dashboard
- Tested all routes automatically (GET, POST for create/edit/delete)

**What went wrong:**
- `better-sqlite3` (native C++ addon) failed to compile in the container — `node-gyp` couldn't build it even after installing `build-essential`. The model tried `sqlite3` (another native driver) which also failed. It then fell back to `sql.js`, a pure-JavaScript SQLite implementation compiled to WebAssembly.
- `sql.js` doesn't enforce `PRAGMA foreign_keys = ON` reliably (the pragma sets correctly, but DELETE operations bypass FK checks). The model initially didn't catch this, which leads to Prompt 4.

### Prompt 4: Repository Organization

> **User prompt:** "Please put everything together into a GitHub repository with proper organization, and make sure everything works and complies"

**What the model did:**
- Rebuilt the entire repository from scratch with a clean directory structure
- Created `setup.sh` for one-command database setup
- Wrote a comprehensive `README.md` mapping every file to its assignment point
- Created a proper `.gitignore`
- Downgraded Express from v5 to v4 in `package.json` for stability
- Ran a full end-to-end test: `setup.sh` → all 5 queries → all app CRUD routes

**What went wrong (and was caught during testing):**
- The FK enforcement bug from `sql.js` was discovered during the end-to-end test. The model tested deleting Publisher #1 (which has games), and the DELETE succeeded when it shouldn't have. The model then added application-level FK checks (querying child tables before allowing deletion) and re-tested to confirm they worked.

---

## 3. What the AI Did Well

- **SQL generation was accurate on the first try.** All 7 CREATE TABLE statements, all INSERT data, and all 5 queries ran without syntax errors. The constraint tests (CHECK, UNIQUE, FK) all passed immediately.
- **Domain modeling was reasonable.** The entity structure naturally satisfied the assignment requirements (≥3 classes, 1:N, M:N relationships) without needing to be forced.
- **The BCNF proofs are correct.** Each relation's functional dependencies and superkey analysis are sound.
- **Automated testing caught real bugs.** The FK enforcement issue was found because the model actually tested the delete operation rather than assuming it worked.
- **Error recovery was effective.** When packages failed to install or files failed to convert, the model tried alternatives rather than giving up.

## 4. What the AI Did Poorly or Couldn't Do

- **Diagram quality is mediocre.** The UML and ERD diagrams were generated as SVGs via hand-written markup. They're technically correct but visually plain compared to what LucidChart, Visual Paradigm, or draw.io would produce. The assignment asks for a LucidChart URL for the ERD — this still needs to be done manually.
- **The SVG conversion was brittle.** The model spent ~6 attempts fixing XML parsing errors that a human would have avoided by using a proper diagramming tool in the first place.
- **The `sql.js` FK issue is a real limitation.** A human developer would likely have installed `better-sqlite3` successfully on a properly configured machine. The application-level FK checks are a workaround, not a fix.
- **No visual design effort on the web app.** The EJS templates use minimal inline CSS. This is adequate for the assignment ("no need to have a polished interface") but wouldn't pass as production code.
- **The model cannot test the UI visually.** It tested routes via `curl` and verified HTTP status codes and response content via grep, but never actually saw the rendered pages in a browser. Visual bugs (layout issues, broken forms) would not have been caught.
- **Requirements PDF is generated, not written.** A human writing the requirements document would likely think more carefully about edge cases and domain nuances. The AI-generated version is correct but formulaic.

## 5. What Still Requires Human Work

| Task | Why AI couldn't do it |
|------|----------------------|
| Recreate UML diagram in a proper tool | The assignment likely expects a tool-generated diagram, not a programmatic SVG |
| Create ERD in LucidChart and get the URL | Assignment specifically asks for a LucidChart URL |
| Verify the domain makes sense for *your* interests | The AI chose Board Game Café — you might prefer a different domain |
| Review BCNF proofs for your own understanding | You need to be able to explain these if called on in class |
| Test the web app in an actual browser | The AI tested via HTTP requests only |
| Switch to `better-sqlite3` on your machine | Will compile correctly on a standard dev machine and has proper FK support |
| Push to GitHub | The AI created the repo structure but can't authenticate with GitHub |

---

## 6. Prompt Engineering Observations

### What worked

- **Uploading the assignment as a document** gave the model full context in one shot. It correctly parsed the point values, submission requirements, and reference links.
- **"Please complete this assignment"** as a single broad prompt worked better than breaking it into sub-tasks. The model naturally sequenced the deliverables in dependency order (requirements → conceptual model → logical model → schema → DDL → data → queries).
- **"Think as a professional software developer and make sure you support your claim with evidence"** produced a more grounded technology recommendation than a generic "what should I use?" would have.
- **"Make sure everything works and complies"** triggered the model to do end-to-end testing rather than just generating files.

### What would improve results

- **Specifying the domain upfront** would have avoided the risk of the AI choosing a domain that doesn't interest you or is too simple/complex.
- **Asking for the diagrams as Mermaid code** instead of SVGs would have been cleaner — Mermaid renders more reliably and can be embedded in markdown.
- **Requesting `better-sqlite3` explicitly** and providing a working dev environment would have avoided the `sql.js` workaround entirely.
- **Iterating on individual components** (e.g., "make query 5 more interesting" or "add more realistic test data") would have improved quality, but wasn't done because the first pass was acceptable.

### Anti-patterns to avoid

- Don't ask the AI to generate a LucidChart diagram — it can't interact with web applications.
- Don't assume FK constraints work without testing. The model caught this, but a less thorough prompt might not have triggered the test.
- Don't skip reviewing the BCNF proofs. They're correct here, but AI can produce plausible-sounding but wrong normalization arguments, especially for schemas with non-obvious functional dependencies.

---

## 7. Reproducibility Guide

To reproduce this project from scratch using Claude (or a similar model):

### Step 1: Set Up

Use Claude with computer use enabled (available on claude.ai with a Pro subscription). Upload your assignment document as a PDF or paste the text.

### Step 2: Generate Core Deliverables

```
Prompt: "I need to build a database for [your domain]. Here is the assignment.
         Please generate: (1) a requirements document, (2) a UML class diagram,
         (3) an ERD, (4) a relational schema with BCNF proof, (5) SQL DDL for
         SQLite, (6) test data, and (7) five queries meeting these requirements:
         [paste query requirements]. Use SQLite3 and create actual files I can
         download."
```

### Step 3: Build the Web App

```
Prompt: "Build a Node + Express + EJS app with CRUD for [Table A] and [Table B]
         (which has a foreign key to Table A). Use the database created above.
         Test all routes."
```

### Step 4: Organize and Validate

```
Prompt: "Organize everything into a clean GitHub repository structure with a
         README that maps each file to the assignment requirements. Run all SQL
         scripts and queries end-to-end to verify everything works."
```

### Step 5: Human Review

- Recreate diagrams in a proper tool (LucidChart, draw.io, Visual Paradigm)
- Read through the BCNF proofs and make sure you can explain them
- Test the web app in a browser
- Replace `sql.js` with `better-sqlite3` if compiling natively on your machine
- Push to GitHub

---

## 8. Time Breakdown

| Phase | AI Time | Human Time (Estimated) |
|-------|---------|----------------------|
| Requirements + domain modeling | ~2 min | 5 min to review |
| UML + ERD diagrams | ~4 min (including SVG debugging) | 30–45 min to recreate in LucidChart |
| BCNF schema + proof | ~1 min | 10 min to review and understand |
| SQL DDL + test data | ~2 min | 5 min to review |
| 5 queries + testing | ~2 min | 10 min to review and understand |
| Node + Express app | ~3 min | 10 min to test in browser |
| Repo organization + end-to-end test | ~3 min | 5 min to push to GitHub |
| **Total** | **~17 min** | **~75–90 min** |

The AI dramatically accelerated the generation of boilerplate (SQL DDL, test data, EJS templates, CRUD routes) but the human review time is non-trivial and non-optional — especially for the BCNF proofs and queries, which you need to be able to explain.

---

## 9. Ethical Considerations

This document exists because transparency about AI usage matters. A few things to keep in mind:

- **The assignment says "completed individually"** — using AI as a tool is different from having another student do the work, but you should confirm your professor's AI policy. Some professors welcome it; others restrict it.
- **You are responsible for understanding the output.** If you submit AI-generated BCNF proofs and can't explain them when called on in class, the AI usage hasn't helped you learn.
- **The AI made the project faster, not effortless.** Reviewing, testing, recreating diagrams in proper tools, and understanding the material still takes real time and effort.
- **This documentation itself is a form of academic integrity.** By documenting exactly what the AI did, you're being honest about your process rather than presenting AI output as purely your own work.
