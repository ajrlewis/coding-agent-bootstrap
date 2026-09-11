# GitHub Flow

This repository uses focused branches and pull requests into `main`.

- Start concise feature or fix branches from the latest `main`; never push directly to `main`.
- Keep each branch and commit focused on one coherent change.
- Commit locally as needed. Do not merge `main` before every commit.
- Before pushing or opening or updating a PR, run `git fetch origin` and merge `origin/main` into the feature branch.
- Resolve conflicts on the feature branch, inspect the resolved diff, and rerun relevant checks from `.agents/COMMANDS.md` before pushing.
- Prefer merge over rebase so shared history is not rewritten and force pushes are unnecessary.
- Push the feature branch and open or update a pull request targeting `main`.
- Inspect CI, required checks, mergeability, and review feedback before considering the change ready.
- Never bypass required checks, rewrite shared history casually, or force-push a shared branch without explicit policy and clear intent.

When the maintainer asks to "branch add commit push and PR," treat that phrase, or a clear equivalent, as authorization to complete the whole delivery sequence. Inspect the worktree and diff, create a focused branch when still on `main`, run relevant checks, stage only the intended files, commit with a descriptive message, merge the latest `origin/main`, rerun checks affected by the merge, push the branch, and open a pull request targeting `main`. Preserve unrelated user changes and return the pull request URL.

When the maintainer reports "PR merged," treat that phrase, or a clear equivalent, as a request to clean up the associated local branch. Identify and remember that branch before switching, require a clean worktree, switch to `main`, run `git pull --ff-only --prune`, show `git branch --merged main`, and delete the associated branch with `git branch -d -- <branch>`. Never force-delete a branch that Git does not recognize as merged; report it instead. If the associated branch is unclear, ask before deleting anything.

Protect `main` with a GitHub rule that requires pull requests, applies to administrators, and blocks direct pushes, force pushes, and deletion. This solo-maintainer repository does not require an approving review because pull request authors cannot approve their own changes. Require the `POSIX and context` and `PowerShell` CI checks before merge.
