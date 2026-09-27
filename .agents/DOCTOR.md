# Agent Context Doctor

Use this procedure when asked to doctor, audit, lint, validate, or refresh the repository's agent context. It checks the routed `.agents/` files against the repository and updates stale context when the request authorizes changes.

1. Read `AGENTS.md`, `CLAUDE.md`, the canonical `.agents/` files, adopted presets, project-specific skills, and MCP capability definitions.
2. Inspect the current repository sources of truth: manifests, lockfiles, task runners, CI, tests, deployment configuration, contributor docs, and recent Git history where useful.
3. Confirm every path routed from `AGENTS.md` exists. When `.agents/BOOTSTRAP.md` is absent, confirm `AGENTS.md` has no bootstrap-only routing instruction. Confirm routing points to `.agents/sessions/ACTIVE.md`, `.agents/sessions/DEFERRED.md`, and `.agents/sessions/archive/`.
4. Compare documented workflow, commands, architecture, boundaries, tools, and integrations with the repository. Remove stale claims, resolve duplication, and keep facts in their natural canonical file.
5. Verify documented commands when practical and safe. Never claim a command passed unless it was run; report commands that could not be verified and why.
6. Keep only adopted presets, project-specific skills, and desired MCP definitions. Check that their instructions do not conflict with project-specific context.
7. Review `.agents/todos/TODO.md`. Remove invalid items, keep actionable unresolved work concise, and move completed items to `.agents/todos/DONE.md` with a completion date and short outcome.
8. Verify exactly one canonical `.agents/sessions/ACTIVE.md` exists. Search the repository, including product directories, for competing `NEXT_SESSION.md`, `ACTIVE.md`, or equivalent active-handoff files. A monorepo still has one workspace-level active session.
9. Check `ACTIVE.md` against current source, specifications, architecture, tests, and recent history. It must describe unfinished work or explicitly say no active objective is selected. Confirm its referenced paths and commands exist.
10. Check completed briefs are under `.agents/sessions/archive/` with, when known, completion status and date, review identifier, merged commit, concise outcome, and verification outcome. Treat them as history only.
11. Check `.agents/sessions/DEFERRED.md` does not contain implemented work or read as implementation authorization. Confirm session guidance does not contradict architecture, specifications, public contracts, or current code.
12. Check that managed directories contain no accidental empty directories and that agent context contains no credentials, temporary migration state, or unsupported claims.
13. Inspect `.agents/VERSION` as the local context-schema marker. Do not claim it is current without comparing it with an explicitly provided or fetched canonical source.
14. Run relevant checks from `.agents/COMMANDS.md`, inspect the final diff, and summarize refreshed files, detected inconsistencies, verification performed, and unresolved gaps.

Do not turn this into a broad code refactor or silently change project policy. Ask the maintainer when a real policy conflict cannot be resolved from repository evidence.

When the user authorizes a context refresh, repair obvious session staleness and archive briefs that repository evidence shows are complete. Do not select product priorities or promote deferred work on the maintainer's behalf.

Doctoring is an in-place audit of the context already installed. Do not fetch or rerun coding-agent-bootstrap during a normal doctor pass. When the maintainer explicitly requests an upstream comparison or upgrade, present rerunning the installer as a separate controlled re-bootstrap: it preserves the current canonical files under `.coding-agent-bootstrap/existing/`, installs fresh bootstrap scaffolds, requires semantic reconciliation, and must finish by removing temporary bootstrap and migration state. It is recoverable migration, not a routine refresh or a destructive reset.
