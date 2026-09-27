# Coding Agent Rules

## 1. Think Before Coding
Do not assume. Surface ambiguity. Understand existing code and context before changing it.

## 2. Keep It Simple
Write the minimum code necessary. Avoid speculative abstractions, unnecessary flexibility, and premature generalization.

## 3. Make Surgical Changes
Change only what the task requires. Preserve existing patterns. Do not refactor unrelated code.

## 4. Work Toward Verifiable Outcomes
Define success. Test the result. Do not declare completion without evidence.

## Where To Look

- `.agents/WORKFLOW.md` - the project's development process.
- `.agents/COMMANDS.md` - canonical verified commands.
- `.agents/ARCHITECTURE.md` - system boundaries and invariants.
- `.agents/DOCTOR.md` - refresh and consistency checks for agent context; use it when asked to doctor, lint, refresh, or audit the agent files.
- `.agents/SECURITY.md` - dependency and code vulnerability audit procedure; use it for security reviews and vulnerability checking.
- `.agents/sessions/ACTIVE.md` - the only active implementation handoff.
- `.agents/sessions/DEFERRED.md` - optional planning input that does not authorize implementation.
- `.agents/sessions/archive/` - completed session briefs retained as historical evidence.
- `.agents/todos/TODO.md` - active agent-managed follow-up work.
- `.agents/todos/DONE.md` - archive of completed agent-managed follow-up work.
- `.agents/presets/` - adopted engineering conventions.
- `.agents/skills/` - recurring specialized procedures, when the project defines them.
- `.agents/mcp/` - desired external capabilities.

If `.agents/BOOTSTRAP.md` exists, complete it before normal project work. During bootstrap, preserve `CLAUDE.md`; project-specific context belongs in the routed `.agents/` files. Remove this paragraph from `AGENTS.md` when bootstrap is complete.

Always read `AGENTS.md`. Read `.agents/sessions/ACTIVE.md` when asked to continue, pick up, implement the next session, or choose the next task, plus relevant product specifications and nested `AGENTS.md` files for local constraints. Do not implement deferred work unless the user explicitly selects an item or asks for planning; archived briefs are historical only. Current code, tests, architecture, and product specifications override stale briefs. If the active brief is complete, stale, contradictory, or selects no objective, report that state and await direction instead of inferring authorization from deferred or archived content. A monorepo has one workspace-level active session; nested `AGENTS.md` files add durable local rules, not active work queues.

## Definition Of Done

Run relevant checks from `.agents/COMMANDS.md`, verify the requested outcome, review the diff, and update durable context when facts changed. When an active session is completed, archive its brief, reconcile deferred work, and replace it with the next explicitly selected brief or state that no objective is selected. Archive completed setup follow-ups in `.agents/todos/DONE.md` and record discovered out-of-scope setup work in `.agents/todos/TODO.md`. Never invent the next priority or claim a check passed unless it was run.
