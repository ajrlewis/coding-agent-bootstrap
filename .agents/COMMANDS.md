# Commands

These commands are canonical for this repository.

## Inspect

```sh
rg --files
git status --short --branch
git diff --check
```

## Install To A Target Repository

Local Linux/macOS install from this checkout:

```sh
./install.sh /path/to/target/repo
```

Preserve existing target configuration for semantic migration:

```sh
./install.sh --merge /path/to/target/repo
```

Remote-style install into the current Git repository:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh
```

Remote merge install:

```sh
curl -fsSL https://raw.githubusercontent.com/ajrlewis/coding-agent-bootstrap/main/install.sh | sh -s -- --merge
```

Local Windows install:

```bat
install.bat C:\path\to\target\repo
```

Windows merge install:

```powershell
.\install.ps1 -Merge C:\path\to\target\repo
```

## Fast Verification

```sh
sh -n install.sh
sh -n tests/install.sh
git diff --check
```

## Full Verification

```sh
sh -n install.sh
sh -n tests/install.sh
sh tests/install.sh
git diff --check
```

PowerShell behavior should also be exercised with `pwsh -File install.ps1` when PowerShell is available. Report explicitly when it is not.
