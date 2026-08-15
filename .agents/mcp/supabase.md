# Supabase MCP Capability

## Capability

Supabase project access.

## Purpose

Useful for inspecting managed PostgreSQL schema, row-level security policies, edge functions, auth configuration, storage, and project metadata.

## Requirement

Optional by default. Required only when Supabase-hosted state affects the task and cannot be inferred locally.

## Expected Scope

Use least-privilege access. Prefer read-only access for inspection tasks.

## Configuration

Host-specific setup may require a project reference and token supplied outside the repository.

## Security Notes

Do not commit access tokens, service role keys, database passwords, or project secrets.
