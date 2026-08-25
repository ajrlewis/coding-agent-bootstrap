# Workflow

> Bootstrap state: discover and replace with the target project's development workflow.

Inspect existing contributor documentation, CI, branch policy, task runners, tests, and recent repository history. Existing repository conventions take precedence over this generic model.

If no project-specific Git policy exists, use `.agents/presets/git/github-flow.md`. It defines when to sync with `origin/main` and requires relevant verification after conflict resolution.

When Linear or another external tracker is the canonical backlog, keep work-item content there rather than mirroring it into `.agents/TODO.md` or another repository file. Document the target project's state transitions and linking conventions here. A typical tracked workflow is:

```text
select a work item
-> fetch its current details through the configured external capability
-> mark it started when implementation actually begins
-> create a typed branch containing the work-item identifier
-> implement and verify the change
-> open a linked pull request
-> update or complete the work item when the corresponding event occurs
```

Use one branch per work item by default. Split a parent item when it needs multiple independently reviewable changes. Preserve existing tracker or Git-host automation instead of duplicating its status updates manually.

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

During bootstrap, account explicitly for the repository's behavior verification and static checks. A missing test or linting category requires a documented rationale, an approved baseline addition, or an actionable entry in `.agents/TODO.md`; it is not an implicit exemption.

Remove this scaffold guidance after documenting the target-specific workflow.
