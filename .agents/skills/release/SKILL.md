# Release Skill

Use this skill when preparing, validating, or cutting a release.

## Procedure

1. Identify the project's release mechanism, versioning policy, and deployment boundary.
2. Read recent changelog, commits, tags, CI results, and release documentation.
3. Confirm the release branch or tag strategy before modifying version files.
4. Run the full verification command from `.agents/COMMANDS.md`.
5. Update release notes or changelog only with user-facing, relevant changes.
6. Avoid bundling unrelated cleanup into release preparation.
7. Confirm published artifacts, deployment status, or package metadata where the project expects it.
8. Record deferred release risks or follow-up work in `.agents/TODO.md`.
