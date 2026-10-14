# Coding Agent Rules

## 1. Think Before Coding
Inspect the existing code and surrounding context before changing it. Do not make silent assumptions. Surface ambiguity that could affect the outcome.

## 2. Keep It Simple
Write the minimum code needed for the requested outcome. Avoid speculative abstractions, unnecessary flexibility, and premature generalization.

## 3. Make Surgical Changes
Change only what the task requires. Preserve existing patterns. Avoid unrelated refactors.

## 4. Work Toward Verifiable Outcomes
Define success before making changes. Run the relevant checks. Do not claim completion without evidence.

## 5. Report Plainly
Write conversational replies in plain, direct language. Use short sentences, active voice, and one idea per sentence. Follow ASD-STE100 roughly, not strictly. Preserve exact identifiers, file names, error strings, and numbers. Preserve every condition and uncertainty, including “if,” “unless,” and “not verified.” Do not simplify wording in a way that implies more certainty. This rule does not apply to code, comments, commit messages, or docstrings.

## Where To Look

- `.agents/WORKFLOW.md` - how development work normally proceeds.
- `.agents/COMMANDS.md` - canonical known-good commands.
- `.agents/ARCHITECTURE.md` - system structure, boundaries, and invariants.
- `.agents/DOCTOR.md` - refresh and consistency checks for agent context; use it when asked to doctor, lint, refresh, or audit the agent files.
- `.agents/SECURITY.md` - dependency and code vulnerability audit procedure; use it for security reviews and vulnerability checking.
- `.agents/sessions/ACTIVE.md` - the only active implementation handoff.
- `.agents/sessions/DEFERRED.md` - unresolved follow-up work and optional planning input that does not authorize implementation.
- `.agents/sessions/archive/` - completed session briefs retained as historical evidence.
- `.agents/presets/` - adopted engineering conventions.
- `.agents/skills/` - recurring specialized procedures.
- `.agents/mcp/` - desired external capabilities for agents.

Always read `AGENTS.md`. Read `.agents/sessions/ACTIVE.md` when asked to continue, pick up, implement the next session, or choose the next task, plus relevant product specifications and nested `AGENTS.md` files for local constraints. Do not implement deferred work unless the user explicitly selects an item or asks for planning; archived briefs are historical only. Current code, tests, architecture, and product specifications override stale briefs. If the active brief is complete, stale, contradictory, or selects no objective, report that state and await direction instead of inferring authorization from deferred or archived content. A monorepo has one workspace-level active session; nested `AGENTS.md` files add durable local rules, not active work queues.

## Definition Of Done

Run relevant checks from `.agents/COMMANDS.md`, verify the requested outcome, review the diff, and update durable context when facts changed. When an active session is completed, archive its brief, reconcile deferred work, and replace it with the next explicitly selected brief or state that no objective is selected. Record unresolved out-of-scope work in `.agents/sessions/DEFERRED.md` when it does not belong in the canonical issue tracker. Never invent the next priority or claim a check passed unless it was run.
