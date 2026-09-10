# Agent TODO

Use this file for active, persistent agent-relevant follow-up work that should survive across sessions. Move completed entries to `DONE.md` with their completion date and a concise outcome.

Do not use it as a per-task execution plan or as a replacement for GitHub Issues, Linear, Jira, or the product backlog.

## Open Items

- Consider adding a tiny `CONTRIBUTING.md` if presets or skills start receiving external contributions. Keep the acceptance rule strict: high signal, low bloat.
- Consider an explicit installer option to initialize Git for empty-project bootstraps. Keep the default conservative.
- Decide whether the bootstrap payload should ship any example skills. The current API, database-migration, and release examples are not universally relevant, and all tracked `SKILL.md` files need required `name` and `description` front matter before Codex can discover them.
- Document a minimal manual upgrade path for previously bootstrapped repositories, beginning with payload v3 to v4. Cover adopting `DOCTOR.md`, splitting active and completed TODOs, and removing stale bootstrap routing without introducing a migration framework.
- Define semantics for read-only installer status and validation commands before adding `--status`, `--resume`, or `--validate`. Mechanical checks can identify temporary state, required filenames, and empty bootstrap-managed directories, but retained presets, MCP applicability, and intentionally rewritten project context require a clear semantic contract.
- Evaluate whether the reusable preset and MCP catalogue can remain outside the target tree until semantic selection without weakening local and remote installation, offline discovery, merge preservation, or rollback behavior.
