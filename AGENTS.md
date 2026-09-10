# Coding Agent Rules

## 1. Think Before Coding
Do not assume. Surface ambiguity. Understand the existing code and surrounding context before changing it.

## 2. Keep It Simple
Write the minimum code necessary. Avoid speculative abstractions, unnecessary flexibility, and premature generalization.

## 3. Make Surgical Changes
Change only what the task requires. Preserve existing patterns. Do not refactor unrelated code.

## 4. Work Toward Verifiable Outcomes
Define what success means. Test the result. Do not declare completion without evidence.

## Where To Look

- `.agents/WORKFLOW.md` - how development work normally proceeds.
- `.agents/COMMANDS.md` - canonical known-good commands.
- `.agents/ARCHITECTURE.md` - system structure, boundaries, and invariants.
- `.agents/DOCTOR.md` - refresh and consistency checks for agent context; use it when asked to doctor, audit, lint, or refresh the agent files.
- `.agents/todos/TODO.md` - active agent-managed follow-up work.
- `.agents/todos/DONE.md` - archive of completed agent-managed follow-up work.
- `.agents/presets/` - adopted engineering conventions.
- `.agents/skills/` - recurring specialized procedures.
- `.agents/mcp/` - desired external capabilities for agents.

## Definition Of Done

Run relevant checks from `.agents/COMMANDS.md`, verify the requested outcome, review the diff, update agent-managed context if facts changed, archive completed follow-up work in `.agents/todos/DONE.md`, and record discovered out-of-scope work in `.agents/todos/TODO.md`. Never claim a check passed unless it was run.
