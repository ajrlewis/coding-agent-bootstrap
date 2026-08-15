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
11. Record deferred, agent-relevant follow-up work in `.agents/TODO.md`.

Use the GitHub Flow preset for repository changes. Do not add a runtime dependency unless the behavior genuinely requires one.
