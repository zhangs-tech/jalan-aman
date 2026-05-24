# AGENTS.md

## 🔍 Code Search (MUST — read this first)

For **every** non-trivial code exploration — tracing how a feature works, finding related symbols, understanding cross-cutting concerns, or investigating a domain like "auth" — make this your **first tool call**:

```
ccc search "<query>" --refresh
```
(via the `bash` tool)

**DO NOT** start with `grep`, `rg`, or `find` when you're trying to understand something. Fall back to lexical tools only for exact-string matching (e.g., counting occurrences, locating a known literal string).

## Project
Hybrid mobile app — **Flutter** frontend (`jalan_aman/`) + **Bun/TypeScript** backend (`backend/`).

## Tooling
- **Documentation**: Use `find-docs` skill when a library is involved — do not rely on training data.

## Safety
- **Always prompt the user for confirmation** before executing any task to avoid unwanted actions. Do not proceed autonomously.

## Nested Instructions
- **Backend work** — see `backend/AGENTS.md` for backend-specific rules.
- **Frontend work** — see `jalan_aman/AGENTS.md` for Flutter-specific conventions.
