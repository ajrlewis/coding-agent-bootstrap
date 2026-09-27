# Workflow

> Bootstrap state: discover and replace with the target project's development workflow.

Inspect existing contributor documentation, CI, branch policy, task runners, tests, and recent repository history. Existing repository conventions take precedence over this generic model.

If no project-specific Git policy exists, adopt the preset matching the repository's Git host: `.agents/presets/git/github-flow.md` for GitHub or `.agents/presets/git/azure-devops.md` for Azure Repos. Both define when to sync with the remote default branch and require relevant verification after conflict resolution.

When Linear or another external tracker is the canonical backlog, keep work-item content there rather than mirroring it into `.agents/todos/TODO.md` or another repository file. Document the target project's state transitions and linking conventions here. A typical tracked workflow is:

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

`.agents/sessions/ACTIVE.md` is the immediate repository handoff, not a backlog mirror. A tracker may remain canonical for priorities and work-item detail. In a monorepo, keep one workspace-level active brief even when it targets one product; nested `AGENTS.md` files provide local durable constraints.

Adapt the normal loop where appropriate:

```text
understand task
-> inspect relevant code, tests, and context
-> read relevant presets and project-specific skills
-> form a plan for non-trivial work
-> make narrow changes
-> run relevant verification from .agents/COMMANDS.md
-> review the diff
-> update agent-managed context if required
-> when the active session is complete, archive its brief and reconcile deferred work
-> replace ACTIVE.md with the next explicitly selected brief or state that no objective is selected
-> archive completed follow-up work in .agents/todos/DONE.md
-> record agent-managed setup follow-ups in .agents/todos/TODO.md
```

Advance the session handoff in the implementation pull request when practical so the merged default branch remains truthful. Move durable facts into their canonical documentation, and include completion metadata in the archived brief. Do not invent a next priority when none has been selected. `.agents/sessions/DEFERRED.md` holds optional product-planning input; `.agents/todos/TODO.md` remains limited to persistent agent-managed setup follow-ups.

Do not require every possible check for every task. Define relevant fast and full verification in `.agents/COMMANDS.md` based on the actual project.

During bootstrap, account explicitly for the repository's behavior verification and static checks. A missing test or linting category requires a documented rationale, an approved baseline addition, or an actionable entry in `.agents/todos/TODO.md`; it is not an implicit exemption.

Also establish the vulnerability-checking workflow described in `.agents/SECURITY.md`: adopted dependency and code scanners, severity thresholds, finding ownership, remediation and exception handling, and the checks that belong in CI. Treat missing or incomplete coverage as an explicit gap.

Remove this scaffold guidance after documenting the target-specific workflow.
