# Monorepo Preset

Use this preset when the repository contains or intentionally plans multiple runnable applications, shared packages, or both. Do not reorganize a focused single application into a monorepo without a concrete boundary or maintainer direction.

```text
apps/
├── web/                  deployable web application
├── api/                  deployable API or service
└── cli/                  runnable command-line application

packages/
└── <reusable>/           shared libraries, contracts, or tooling
```

- Create only directories that represent real components. The names above are conventional examples, not mandatory empty scaffolding.
- Treat each `apps/` child as an independently runnable or deployable product boundary with explicit configuration, entrypoints, ownership, and verification.
- Put genuinely reusable code in focused `packages/` modules with deliberate public APIs. Do not create a generic `shared`, `common`, or `utils` dumping ground.
- Keep dependency direction clear: applications may depend on packages; packages must not reach into applications; avoid cyclic package dependencies.
- Extract a package when a stable domain or technical boundary justifies it, not merely because code might be reused later.
- Keep one root workspace definition and lockfile where the ecosystem supports it. Centralize truly shared tool configuration while allowing application-specific configuration where behavior differs.
- Keep cross-application contracts explicit and versioned or generated from one canonical source. For example, generate TypeScript validation and types from an adopted API schema rather than maintaining equivalent Zod and Pydantic models by hand.
- Keep tests close to the code they verify. Share test helpers only when they represent a real reusable testing capability.
- Define root commands for focused application or package work and for full-repository verification. Record exact workspace filters, dependency order, build, test, lint, typecheck, and development commands in `.agents/COMMANDS.md`.
- Let CI use affected-component optimization only when dependency detection is trustworthy; retain full verification for release and other high-risk paths.
- Keep repository-wide infrastructure in a clear root boundary such as `infra/` when it is not owned by one application, and document deployment ownership in `.agents/ARCHITECTURE.md`.
- For JavaScript or TypeScript workspaces, Turborepo is a reasonable task-orchestration and caching default when multiple real packages exist. For Python, prefer `uv` workspaces for shared dependency resolution and locking; recognize that `uv` is not a task-graph or build-cache equivalent to Turborepo.
- In a polyglot monorepo, prefer a small root command layer over forcing every ecosystem through one tool. Adopt Pants, Bazel, or another cross-language build system only when repository scale and dependency complexity justify it.
- Document the actual workspace tree, dependency direction, shared package contracts, and deployment boundaries in `.agents/ARCHITECTURE.md` after discovery.
