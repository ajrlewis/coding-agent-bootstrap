# Docker Preset

- Keep images small, reproducible, and aligned with the repository's runtime choices.
- Avoid baking secrets into images or compose files.
- Separate development conveniences from production runtime requirements.
- Prefer explicit health checks and startup dependencies where they improve local reliability.
- Rebuild and run the relevant services after Dockerfile or compose changes.
- Record canonical Docker commands in `.agents/COMMANDS.md`.
