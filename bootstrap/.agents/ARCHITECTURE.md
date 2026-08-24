# Architecture

> Bootstrap state: replace this guidance with project-specific architecture.

Document the durable architectural context a coding agent needs to make safe changes.

Include where relevant:

- major components and responsibilities;
- dependency direction and architectural boundaries;
- important data flows and persistence boundaries;
- external services and public interfaces;
- generated code;
- deployment and runtime boundaries;
- critical invariants;
- areas requiring particular care.

For adopted hosted services, name the canonical source for each kind of state and document sync direction instead of listing disconnected vendors. For example, when the project uses this arrangement:

```text
Doppler
├── syncs runtime secrets -> Vercel
└── syncs service secrets -> Supabase

repository documentation
└── publishes through -> Mintlify
```

Record which repository files own deployment configuration, database migrations, edge functions, and documentation. Distinguish development, preview, staging, and production authority, and identify external mutations that require maintainer approval. Keep only relationships the target project actually adopts.

Prefer boundaries and relationships over exhaustive directory listings. Inspect the repository before documenting this file. Do not speculate; distinguish observable facts from assumptions.

Remove this bootstrap guidance once project-specific architecture has been documented.
