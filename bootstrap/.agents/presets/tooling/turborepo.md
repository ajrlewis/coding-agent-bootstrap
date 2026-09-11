# Turborepo Preset

- Use Turborepo when a JavaScript or TypeScript workspace has multiple real applications or packages that benefit from dependency-aware task orchestration and caching. Do not add it to a single Next.js application without a demonstrated need.
- Keep the selected package manager's workspace configuration and lockfile as the package graph and dependency source of truth.
- Define task dependencies, inputs, outputs, and environment inputs accurately. Cache only deterministic work; never treat deployments or other external mutations as cacheable tasks.
- Expose clear root commands for development, build, lint, typecheck, unit tests, integration tests, and focused package execution.
- Keep remote-cache credentials outside the repository and make local development usable without privileged production access.
- Use filtering or affected-task execution when it is trustworthy, while retaining a full-repository verification path for releases and high-risk changes.
- Do not force Python or other non-workspace components through artificial package wrappers solely to make Turborepo invoke them. Use a small root command layer for polyglot orchestration unless the repository has adopted a dedicated multi-language build system.
- Record verified Turborepo commands and cache assumptions in `.agents/COMMANDS.md` and workspace boundaries in `.agents/ARCHITECTURE.md`.
