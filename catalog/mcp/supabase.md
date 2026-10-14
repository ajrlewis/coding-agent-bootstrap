# Supabase MCP Capability

## Capability

Supabase project access.

## Purpose

Useful for inspecting managed PostgreSQL schema, row-level security policies, edge functions, auth configuration, storage, and project metadata.

## Requirement

Optional by default. Required only when Supabase-hosted state affects the task and cannot be inferred locally.

## Source Of Truth

Keep schema migrations, edge-function source, generated types, and other versioned configuration in the repository. Treat Supabase as the source of truth for live project state. When Doppler is the canonical secret manager and syncs values to Supabase, do not create or edit duplicate secret values directly in Supabase unless the maintainer explicitly adopts that exception.

## Expected Scope

Use least-privilege access. Scope the official hosted MCP server to the relevant project, enable read-only mode for inspection, and expose only the feature groups needed for the task. Development access does not imply production access. Applying migrations, changing data or policies, deploying functions, managing branches, or changing production configuration requires explicit authorization.

## Local Tooling

Supabase's hosted remote MCP server does not require the `supabase` CLI. Local development, migrations, type generation, or a local Supabase MCP endpoint do require the CLI; prefer a pinned project development dependency. Running the local stack also requires a compatible container runtime. Record the package-runner form the repository adopts.

## Configuration

Prefer the official hosted MCP server and OAuth when supported. Keep the project reference and host-specific authentication outside the repository where practical. The server supports project scoping, read-only access, and feature-group restrictions; use all three proportionally. Record exact verified local Supabase commands in `.agents/COMMANDS.md`.

See the official [Supabase MCP documentation](https://supabase.com/docs/guides/ai-tools/mcp).

## Security Notes

Do not commit access tokens, service role keys, database passwords, or project secrets. Avoid production data unless the task explicitly requires it, minimize returned rows and fields, and do not copy sensitive records into agent output.
