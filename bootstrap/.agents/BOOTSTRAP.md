# Bootstrap Procedure

This file is temporary. Its presence means coding-agent setup is not complete.

The canonical Markdown files installed beside it are temporary writing scaffolds. Rewrite them as concise, target-project-specific context; do not leave generic bootstrap prose in place indefinitely.

## Goal

Inspect the target repository, reconcile any existing agent configuration, generate concise project-specific context, validate important assumptions, then remove temporary bootstrap state.

## Existing Configuration Migration

If `.coding-agent-bootstrap/existing/` exists, this repository had coding-agent configuration before bootstrap. Read all relevant preserved files before finalizing the canonical system.

This directory is recoverable migration input, not durable project context. Do not commit it as the final configuration or remove it before reconciliation succeeds.

1. Treat preserved configuration as project-specific source material.
2. Preserve useful project intent and unresolved requirements.
3. Migrate durable information into its natural canonical location:
   - exact commands into `.agents/COMMANDS.md`;
   - development process into `.agents/WORKFLOW.md`;
   - system boundaries and invariants into `.agents/ARCHITECTURE.md`;
   - persistent deferred work into `.agents/TODO.md`;
   - adopted stack or workflow conventions into `.agents/presets/`;
   - reusable task procedures into `.agents/skills/`;
   - desired external capabilities into `.agents/mcp/`.
4. Deduplicate compatible information instead of repeating it across files.
5. Existing repository conventions take precedence over generic presets.
6. Do not discard rules merely because bootstrap defaults differ.
7. Never silently resolve conflicting behavioral or workflow policies. Identify their likely sources, ask the maintainer when intent is unclear, and preserve existing project-specific intent until resolved.
8. Remove `.coding-agent-bootstrap/` only after migration and validation are complete.

## Procedure

1. Inspect before asking. Do not ask questions the repository can answer.
2. Read likely sources of truth: package manifests, lockfiles, build config, CI config, Docker files, test config, linter/formatter config, Makefiles or task runners, source layout, docs, migrations, deployment config, and Git history where useful.
3. Deliberately inspect existing agent guidance beyond the paths preserved by the installer, such as `.cursor/`, `.github/copilot-instructions.md`, agent-specific entrypoints, and custom project documentation. This list is illustrative, not exhaustive; discover existing intent without making the canonical system vendor-specific.
4. Classify what you learn:
   - Discovered facts: directly observable in the repository.
   - Declared facts: explicitly provided by the maintainer.
   - Derived conclusions: reasonable conclusions from discovered or declared facts.
5. Identify the stack, canonical commands, architecture and data flows, important boundaries, existing workflow and conventions, useful presets, recurring procedures worth keeping as skills, and useful MCP capabilities.
6. Existing repository conventions take precedence over generic presets. Do not replace an intentional stack or workflow merely because a preset prefers something else. If no Git policy exists, adopt `.agents/presets/git/github-flow.md` as the default.
7. When GitHub Flow is adopted, complete the remote repository protection checks in [GitHub Flow Protection](#github-flow-protection).
8. Ask the maintainer only for unresolved facts or meaningful policy conflicts, such as project goals, invisible constraints, compatibility requirements, protected areas, deployment/release constraints, security requirements, or a project-specific definition of done.
9. Rewrite the scaffold canonical files into concise target-specific documentation:
   - `.agents/WORKFLOW.md`
   - `.agents/COMMANDS.md`
   - `.agents/ARCHITECTURE.md`
   - `.agents/TODO.md`
   - `.agents/presets/`
   - `.agents/skills/`
   - `.agents/mcp/`
10. Tailor adopted presets to the repository. Keep only project-relevant durable context; remove obsolete or unselected presets, skills, and MCP capability files.
11. Validate documented commands where practical before presenting them as canonical. Never claim a check passed unless it was run; state what could not be run and why.
12. Check that instructions do not contradict each other or duplicate the same knowledge in multiple places.
13. Remove `.agents/BOOTSTRAP.md` and `.coding-agent-bootstrap/` only after setup and any migration are genuinely complete.

## GitHub Flow Protection

When the repository adopts GitHub Flow:

1. Detect whether `origin` is hosted on GitHub and identify the remote default branch instead of assuming it is named `main`.
2. Inspect the default branch's current GitHub ruleset or branch protection through an authenticated GitHub API client when access is available.
3. For a shared repository, require pull requests with at least one approving review, enforce the rule for administrators, and block force pushes and branch deletion. These settings must prevent direct pushes to the default branch.
4. In a solo repository, surface that authors cannot approve their own pull requests and ask the maintainer whether to require an external approval. Still require pull requests and prevent direct and force pushes unless the maintainer explicitly adopts another policy.
5. Obtain explicit maintainer authorization before creating or changing remote repository settings. Local workflow instructions do not by themselves authorize an external mutation.
6. Verify the effective settings after any change. If authentication, repository administration permission, or supported GitHub access is unavailable, record the unresolved protection work in `.agents/TODO.md`, report it clearly, and do not claim remote protection was configured.

Do not add GitHub CLI or another provider SDK as a project dependency solely for this check. Remote protection belongs to the agent-led bootstrap procedure, not the mechanical file installer.

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
- Silently choosing between conflicting existing and bootstrap policies.
- Keeping every bootstrap preset in the target repository.
- Leaving scaffold instructions in canonical files instead of replacing them with project facts.
- Turning `.agents/TODO.md` into a per-task plan or product backlog.
- Removing preserved configuration before migration has been reviewed and validated.
- Leaving temporary bootstrap or migration state in place after setup succeeds.
