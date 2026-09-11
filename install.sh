#!/bin/sh
set -eu

REPOSITORY_URL=${CAB_INSTALL_REPOSITORY:-https://github.com/ajrlewis/coding-agent-bootstrap.git}
REPOSITORY_REF=${CAB_INSTALL_REF:-main}
INSTALL_BRANCH=chore/coding-agent-bootstrap
AGENT_PROMPT='Complete .agents/BOOTSTRAP.md for this repository before normal project work. Do not scaffold or implement the application unless separately requested.'

usage() {
  echo "Usage: install.sh [--merge] [--allow-current-branch] [codex|claude] [target-repository]"
  echo
  echo "Options:"
  echo "  --merge                 Preserve existing configuration (the default; retained for compatibility)."
  echo "  --allow-current-branch  Skip automatic branch creation on the repository's default branch."
  echo "  codex, --codex          Start Codex with the bootstrap prompt after installation."
  echo "  claude, --claude        Start Claude Code with the bootstrap prompt after installation."
  echo "  -h, --help              Show this help."
}

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

copy_path() {
  if [ -d "$1" ] && [ ! -L "$1" ]; then
    cp -Rp "$1" "$2"
  else
    cp -p "$1" "$2"
  fi
}

remove_path() {
  if [ -d "$1" ] && [ ! -L "$1" ]; then
    rm -rf "$1"
  else
    rm -f "$1"
  fi
}

ALLOW_CURRENT_BRANCH=0
START_AGENT=
TARGET_ARGUMENT=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --merge)
      # Existing configuration is always preserved. Retain this option for compatibility.
      ;;
    --allow-current-branch)
      ALLOW_CURRENT_BRANCH=1
      ;;
    codex|--codex)
      if [ -n "$START_AGENT" ]; then
        echo "error: expected at most one agent to start" >&2
        exit 1
      fi
      START_AGENT=codex
      ;;
    claude|--claude)
      if [ -n "$START_AGENT" ]; then
        echo "error: expected at most one agent to start" >&2
        exit 1
      fi
      START_AGENT=claude
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      if [ "$#" -gt 1 ]; then
        echo "error: expected at most one target repository" >&2
        usage >&2
        exit 1
      fi
      if [ "$#" -eq 1 ]; then
        TARGET_ARGUMENT=$1
      fi
      break
      ;;
    -*)
      echo "error: unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -n "$TARGET_ARGUMENT" ]; then
        echo "error: expected at most one target repository" >&2
        usage >&2
        exit 1
      fi
      TARGET_ARGUMENT=$1
      ;;
  esac
  shift
done

TARGET_DIR=${TARGET_ARGUMENT:-$(pwd)}
DOWNLOAD_DIR=
STAGE_DIR=
MIGRATION_DIR=
MIGRATION_INSTALLED=0
INSTALLED_AGENTS_MD=0
INSTALLED_CLAUDE_MD=0
INSTALLED_AGENTS_DIR=0
EXISTING_AGENTS_MD=0
EXISTING_CLAUDE_MD=0
EXISTING_AGENTS_DIR=0
INSTALL_COMPLETE=0

restore_existing_configuration() {
  restore_failed=0

  if [ "$EXISTING_AGENTS_MD" -eq 1 ]; then
    if path_exists "$TARGET_DIR/AGENTS.md" || ! copy_path "$MIGRATION_DIR/existing/AGENTS.md" "$TARGET_DIR/AGENTS.md"; then
      restore_failed=1
    fi
  fi
  if [ "$EXISTING_CLAUDE_MD" -eq 1 ]; then
    if path_exists "$TARGET_DIR/CLAUDE.md" || ! copy_path "$MIGRATION_DIR/existing/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"; then
      restore_failed=1
    fi
  fi
  if [ "$EXISTING_AGENTS_DIR" -eq 1 ]; then
    if path_exists "$TARGET_DIR/.agents" || ! copy_path "$MIGRATION_DIR/existing/.agents" "$TARGET_DIR/.agents"; then
      restore_failed=1
    fi
  fi

  if [ "$restore_failed" -eq 0 ]; then
    if ! rm -rf "$MIGRATION_DIR"; then
      echo "warning: restored original configuration but could not remove migration state: $MIGRATION_DIR" >&2
    fi
  else
    echo "warning: automatic rollback was incomplete" >&2
    echo "Preserved configuration remains at: $MIGRATION_DIR/existing" >&2
  fi
}

cleanup() {
  status=$?
  trap - EXIT HUP INT TERM

  if [ "$status" -ne 0 ] && [ "$INSTALL_COMPLETE" -eq 0 ]; then
    [ "$INSTALLED_AGENTS_MD" -eq 0 ] || remove_path "$TARGET_DIR/AGENTS.md" || :
    [ "$INSTALLED_CLAUDE_MD" -eq 0 ] || remove_path "$TARGET_DIR/CLAUDE.md" || :
    [ "$INSTALLED_AGENTS_DIR" -eq 0 ] || remove_path "$TARGET_DIR/.agents" || :
    [ "$MIGRATION_INSTALLED" -eq 0 ] || restore_existing_configuration || :
  fi

  [ -z "$STAGE_DIR" ] || [ ! -d "$STAGE_DIR" ] || rm -rf "$STAGE_DIR" || :
  [ -z "$DOWNLOAD_DIR" ] || [ ! -d "$DOWNLOAD_DIR" ] || rm -rf "$DOWNLOAD_DIR" || :
  exit "$status"
}

trap cleanup EXIT
trap 'exit 1' HUP INT TERM

if [ ! -d "$TARGET_DIR" ]; then
  echo "error: target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

TARGET_DIR=$(CDPATH= cd -- "$TARGET_DIR" && pwd)
MIGRATION_DIR=$TARGET_DIR/.coding-agent-bootstrap

if ! command -v git >/dev/null 2>&1; then
  echo "error: Git is required to inspect the target repository" >&2
  exit 1
fi

if [ -n "$START_AGENT" ] && ! command -v "$START_AGENT" >/dev/null 2>&1; then
  echo "error: requested agent is not installed or not on PATH: $START_AGENT" >&2
  exit 1
fi

if ! path_exists "$TARGET_DIR/.git"; then
  if ! git -C "$TARGET_DIR" init --quiet; then
    echo "error: unable to initialize a Git repository in: $TARGET_DIR" >&2
    exit 1
  fi
  echo "Initialized Git repository in:"
  echo "  $TARGET_DIR"
fi

SOURCE_DIR=
case "$0" in
  sh|-sh|dash|-dash|bash|-bash|zsh|-zsh)
    ;;
  *)
    if [ -f "$0" ]; then
      SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    fi
    ;;
esac

if [ -n "$SOURCE_DIR" ] && [ -f "$SOURCE_DIR/bootstrap/AGENTS.md" ] && [ -d "$SOURCE_DIR/bootstrap/.agents" ]; then
  if [ "$SOURCE_DIR" = "$TARGET_DIR" ]; then
    echo "error: source and target are the same directory" >&2
    echo "Run the installer from inside the target repository via curl, or pass a different target path." >&2
    exit 1
  fi
fi

if [ "$ALLOW_CURRENT_BRANCH" -eq 0 ] && git -C "$TARGET_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
  CURRENT_BRANCH=$(git -C "$TARGET_DIR" symbolic-ref --quiet --short HEAD 2>/dev/null || :)
  if [ -n "$CURRENT_BRANCH" ]; then
    DEFAULT_BRANCH=$(git -C "$TARGET_DIR" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || :)
    DEFAULT_BRANCH=${DEFAULT_BRANCH#origin/}
    if [ -z "$DEFAULT_BRANCH" ]; then
      case "$CURRENT_BRANCH" in
        main|master) DEFAULT_BRANCH=$CURRENT_BRANCH ;;
      esac
    fi

    if [ -n "$DEFAULT_BRANCH" ] && [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
      if git -C "$TARGET_DIR" show-ref --verify --quiet "refs/heads/$INSTALL_BRANCH"; then
        echo "error: install branch already exists: $INSTALL_BRANCH" >&2
        echo "Switch to, rename, or remove that branch before installing." >&2
        exit 1
      fi
      if ! git -C "$TARGET_DIR" switch --quiet -c "$INSTALL_BRANCH"; then
        echo "error: unable to create install branch: $INSTALL_BRANCH" >&2
        exit 1
      fi
      echo "Created and switched to install branch:"
      echo "  $INSTALL_BRANCH"
    fi
  fi
fi

path_exists "$TARGET_DIR/AGENTS.md" && EXISTING_AGENTS_MD=1
path_exists "$TARGET_DIR/CLAUDE.md" && EXISTING_CLAUDE_MD=1
path_exists "$TARGET_DIR/.agents" && EXISTING_AGENTS_DIR=1
HAS_EXISTING=0
if [ "$EXISTING_AGENTS_MD" -eq 1 ] || [ "$EXISTING_CLAUDE_MD" -eq 1 ] || [ "$EXISTING_AGENTS_DIR" -eq 1 ]; then
  HAS_EXISTING=1
fi

if path_exists "$MIGRATION_DIR"; then
  echo "error: temporary migration state already exists: $MIGRATION_DIR" >&2
  echo "Complete or remove the existing migration state before running the installer again." >&2
  exit 1
fi

if [ -n "$SOURCE_DIR" ] && [ -f "$SOURCE_DIR/bootstrap/AGENTS.md" ] && [ -d "$SOURCE_DIR/bootstrap/.agents" ]; then
  PAYLOAD_DIR=$SOURCE_DIR/bootstrap
else
  DOWNLOAD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/coding-agent-bootstrap.XXXXXX")
  echo "Fetching coding-agent-bootstrap..."
  if ! git clone --quiet --depth 1 --branch "$REPOSITORY_REF" "$REPOSITORY_URL" "$DOWNLOAD_DIR/repository"; then
    echo "error: unable to fetch coding-agent-bootstrap from $REPOSITORY_URL" >&2
    exit 1
  fi
  PAYLOAD_DIR=$DOWNLOAD_DIR/repository/bootstrap
fi

if [ ! -f "$PAYLOAD_DIR/AGENTS.md" ] ||
   [ ! -f "$PAYLOAD_DIR/CLAUDE.md" ] ||
   [ ! -d "$PAYLOAD_DIR/.agents" ] ||
   [ ! -f "$PAYLOAD_DIR/.agents/BOOTSTRAP.md" ]; then
  echo "error: bootstrap payload is incomplete" >&2
  exit 1
fi

STAGE_DIR=$(mktemp -d "$TARGET_DIR/.coding-agent-bootstrap-stage.XXXXXX")
mkdir -p "$STAGE_DIR/payload/.agents"
cp -p "$PAYLOAD_DIR/AGENTS.md" "$STAGE_DIR/payload/AGENTS.md"
cp -p "$PAYLOAD_DIR/CLAUDE.md" "$STAGE_DIR/payload/CLAUDE.md"
cp -Rp "$PAYLOAD_DIR/.agents/." "$STAGE_DIR/payload/.agents/"

if [ "$HAS_EXISTING" -eq 1 ]; then
  mkdir -p "$STAGE_DIR/migration/existing"
  [ "$EXISTING_AGENTS_MD" -eq 0 ] || copy_path "$TARGET_DIR/AGENTS.md" "$STAGE_DIR/migration/existing/AGENTS.md"
  [ "$EXISTING_CLAUDE_MD" -eq 0 ] || copy_path "$TARGET_DIR/CLAUDE.md" "$STAGE_DIR/migration/existing/CLAUDE.md"
  [ "$EXISTING_AGENTS_DIR" -eq 0 ] || copy_path "$TARGET_DIR/.agents" "$STAGE_DIR/migration/existing/.agents"

  mv "$STAGE_DIR/migration" "$MIGRATION_DIR"
  MIGRATION_INSTALLED=1

  [ "$EXISTING_AGENTS_MD" -eq 0 ] || remove_path "$TARGET_DIR/AGENTS.md"
  [ "$EXISTING_CLAUDE_MD" -eq 0 ] || remove_path "$TARGET_DIR/CLAUDE.md"
  [ "$EXISTING_AGENTS_DIR" -eq 0 ] || remove_path "$TARGET_DIR/.agents"
fi

mv "$STAGE_DIR/payload/AGENTS.md" "$TARGET_DIR/AGENTS.md"
INSTALLED_AGENTS_MD=1
mv "$STAGE_DIR/payload/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
INSTALLED_CLAUDE_MD=1
mv "$STAGE_DIR/payload/.agents" "$TARGET_DIR/.agents"
INSTALLED_AGENTS_DIR=1
INSTALL_COMPLETE=1

echo "Installed coding-agent-bootstrap into:"
echo "  $TARGET_DIR"
if [ "$HAS_EXISTING" -eq 1 ]; then
  echo
  echo "Existing coding-agent configuration was preserved at:"
  echo "  .coding-agent-bootstrap/existing/"
fi
echo
echo "Canonical files installed."
echo
echo "Next:"
echo "- Read AGENTS.md and complete .agents/BOOTSTRAP.md before normal project work."
echo "- For README-first repositories, treat README.md as the target-state specification."
echo "- Do not scaffold or implement the application unless separately requested."
echo "- Preserve CLAUDE.md; remove only the bootstrap-routing paragraph from AGENTS.md after setup succeeds."

if [ -n "$START_AGENT" ]; then
  [ -z "$STAGE_DIR" ] || [ ! -d "$STAGE_DIR" ] || rm -rf "$STAGE_DIR"
  STAGE_DIR=
  [ -z "$DOWNLOAD_DIR" ] || [ ! -d "$DOWNLOAD_DIR" ] || rm -rf "$DOWNLOAD_DIR"
  DOWNLOAD_DIR=

  echo
  echo "Starting $START_AGENT in:"
  echo "  $TARGET_DIR"

  if ( : </dev/tty ) 2>/dev/null; then
    case "$START_AGENT" in
      codex) codex -C "$TARGET_DIR" "$AGENT_PROMPT" </dev/tty ;;
      claude) (cd "$TARGET_DIR" && claude "$AGENT_PROMPT" </dev/tty) ;;
    esac
  else
    case "$START_AGENT" in
      codex) codex -C "$TARGET_DIR" "$AGENT_PROMPT" ;;
      claude) (cd "$TARGET_DIR" && claude "$AGENT_PROMPT") ;;
    esac
  fi
fi
