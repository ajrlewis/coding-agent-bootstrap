# Workflow

Normal development work should follow this loop:

1. Understand the task and expected outcome.
2. Inspect relevant code, tests, docs, and agent context.
3. Check applicable presets and skills.
4. Form a short plan for non-trivial work.
5. Make narrow changes that preserve local patterns.
6. Run the relevant canonical commands from `.agents/COMMANDS.md`.
7. Inspect the diff.
8. Update docs or agent-managed context if the facts changed.
9. Record deferred, agent-relevant follow-up work in `.agents/TODO.md`.

For this bootstrap repository, keep changes small and dependency-free unless a runtime is clearly justified.
