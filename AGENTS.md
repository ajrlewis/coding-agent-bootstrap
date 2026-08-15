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
- `.agents/TODO.md` - persistent agent-managed follow-up work.
- `.agents/presets/` - adopted engineering conventions.
- `.agents/skills/` - recurring specialized procedures.
- `.agents/mcp/` - desired external capabilities for agents.

If `.agents/BOOTSTRAP.md` exists, complete that first-run setup before normal implementation work.

## Definition Of Done

Run relevant checks, verify the requested outcome, review the diff, update agent-managed context if facts changed, and record discovered out-of-scope work in `.agents/TODO.md`.
