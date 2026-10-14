# Deferred Work

Unresolved follow-up work and optional future product work may be recorded here as planning input. Entries do not authorize implementation.

Before selecting an entry, check it against the current repository, specifications, architecture, and recent history, then rewrite it as one bounded brief in `.agents/sessions/ACTIVE.md`. Ask the maintainer when priorities conflict or remain ambiguous.

Do not use this file as a per-task plan or as a mirror of an external tracker.

## Deferred Items

- Consider adding a tiny `CONTRIBUTING.md` if presets or skills start receiving external contributions. Keep the acceptance rule strict: high signal, low bloat.
- Decide whether the bootstrap payload should ship any example skills. The current API, database-migration, and release examples are not universally relevant, and all tracked `SKILL.md` files need required `name` and `description` front matter before Codex can discover them.
- Define and document a deliberate upgrade/re-bootstrap workflow for previously bootstrapped repositories. Cover safe upstream version comparison, the current installer's preserve-and-reconcile behavior, migration from payload v3 to v4, recovery from an interrupted upgrade, and final cleanup without turning routine doctoring into an implicit network fetch or reinstall.
- Define semantics for read-only installer status and validation commands before adding `--status`, `--resume`, or `--validate`. Mechanical checks can identify temporary state, required filenames, and empty bootstrap-managed directories, but retained presets, MCP applicability, and intentionally rewritten project context require a clear semantic contract.
