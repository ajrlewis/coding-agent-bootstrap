# Prisma Preset

- Treat `schema.prisma` as the source for Prisma-managed schema changes.
- Use the repository's established Prisma migration workflow, such as `prisma migrate dev` locally and deploy-oriented migration commands in CI or release.
- Review generated SQL before applying risky changes.
- Keep generated client output in sync with schema changes according to project policy.
- Do not edit applied migration history casually.
- Record verified Prisma commands in `.agents/COMMANDS.md`.
