# Release

Use this procedure when publishing a bootstrap version.

1. Confirm the payload schema change and choose the next `bootstrap/.agents/VERSION` value.
2. Run the full verification documented in `.agents/COMMANDS.md`.
3. Inspect the installed fixture, README installation instructions, and final diff.
4. Confirm `main` contains the intended commit before creating a tag or release.
5. Record user-visible behavior changes in release notes without unrelated cleanup.
