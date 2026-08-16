# Workflow

> Bootstrap state: discover and replace with the target project's development workflow.

Inspect existing contributor documentation, CI, branch policy, task runners, tests, and recent repository history. Existing repository conventions take precedence over this generic model.

If no project-specific Git policy exists, use `.agents/presets/git/github-flow.md`. It defines when to sync with `origin/main` and requires relevant verification after conflict resolution.

Adapt the normal loop where appropriate:

```text
understand task
-> inspect relevant code, tests, and context
-> read relevant presets and skills
-> form a plan for non-trivial work
-> make narrow changes
-> run relevant verification from .agents/COMMANDS.md
-> review the diff
-> update agent-managed context if required
-> record deferred work in .agents/TODO.md
```

Do not require every possible check for every task. Define relevant fast and full verification in `.agents/COMMANDS.md` based on the actual project.

Remove this scaffold guidance after documenting the target-specific workflow.
