# Workflow

Changes to `coding-agent-bootstrap` should follow this loop:

1. Understand the task and expected outcome.
2. Inspect relevant code, tests, docs, and agent context.
3. Check applicable root presets and skills.
4. Form a short plan for non-trivial work.
5. Keep source-repository configuration separate from the installable `bootstrap/` payload.
6. Make narrow, dependency-free changes that preserve the small conceptual model.
7. Run the relevant commands from `.agents/COMMANDS.md`.
8. Test installer changes against temporary Git repositories, including clean, refusal, merge-preservation, remote, and rollback-relevant paths.
9. Inspect the diff and installed result for accidental root-context leakage.
10. Update README or agent-managed context if behavior or architecture changed.
11. When an active session is completed, update durable documentation, archive its brief with completion metadata, reconcile deferred work, and replace `ACTIVE.md` with the next explicitly selected brief or state that no objective is selected. Prefer doing this in the implementation pull request; never invent the next priority.
12. Move completed setup follow-ups to `.agents/todos/DONE.md` and record new agent-managed setup work in `.agents/todos/TODO.md`. Keep optional future product slices in `.agents/sessions/DEFERRED.md`, where they remain planning input rather than implementation authorization.

Use the GitHub Flow preset for repository changes, including merging the latest `origin/main` before pushing or updating a PR and rerunning relevant verification afterward. Do not add a runtime dependency unless the behavior genuinely requires one.

External trackers may remain the canonical backlog. `.agents/sessions/ACTIVE.md` is only the immediate repository handoff, and a monorepo uses one workspace-level active brief even when its scope is one product.
