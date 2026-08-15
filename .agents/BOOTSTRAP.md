# Bootstrap Procedure

This file is temporary. Its presence means coding-agent setup is not complete.

## Goal

Inspect this repository, generate concise project-specific agent context, validate the important assumptions, then remove this file.

## Procedure

1. Inspect before asking. Do not ask questions the repository can answer.
2. Read likely sources of truth: package manifests, lockfiles, build config, CI config, Docker files, test config, linter/formatter config, Makefiles or task runners, source layout, docs, migrations, deployment config, and Git history where useful.
3. Classify what you learn:
   - Discovered facts: directly observable in the repository.
   - Declared facts: explicitly provided by the maintainer.
   - Derived conclusions: reasonable conclusions from discovered or declared facts.
4. Identify the stack, canonical commands, architecture, important boundaries, existing conventions, useful presets, recurring procedures worth turning into skills, and useful MCP capabilities.
5. Prefer existing project conventions over bootstrap defaults.
6. Ask the maintainer only for unresolved facts, such as project goals, invisible constraints, compatibility requirements, protected areas, deployment/release constraints, security requirements, or a project-specific definition of done.
7. Populate or update:
   - `.agents/WORKFLOW.md`
   - `.agents/COMMANDS.md`
   - `.agents/ARCHITECTURE.md`
   - `.agents/TODO.md`
   - `.agents/presets/`
   - `.agents/skills/`
   - `.agents/mcp/`
8. Keep only project-relevant durable context. Remove unused presets, skills, and MCP capability files.
9. Validate documented commands where practical before presenting them as canonical.
10. Check that instructions do not contradict each other or duplicate the same knowledge in multiple places.
11. Remove `.agents/BOOTSTRAP.md` after successful setup.

## Good Maintainer Questions

- What is the primary goal of this project?
- What constraints are not visible from the code?
- Are there compatibility requirements?
- Are there areas agents must not modify without approval?
- What deployment or release constraints exist?
- What does "done" mean beyond automated checks?
- Are there product, privacy, or security requirements that cannot be inferred?

## Avoid

- Asking what language or framework the repository uses when manifests make that clear.
- Treating presets as higher authority than the existing codebase.
- Keeping every bootstrap preset in the target repository.
- Turning `.agents/TODO.md` into a per-task plan or product backlog.
- Leaving this file in place after setup succeeds.
