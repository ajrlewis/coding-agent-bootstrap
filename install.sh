#!/bin/sh
set -eu

REPOSITORY_URL=${CAB_INSTALL_REPOSITORY:-https://github.com/ajrlewis/coding-agent-bootstrap.git}
REPOSITORY_REF=${CAB_INSTALL_REF:-main}

usage() {
  echo "Usage: install.sh [--merge] [--allow-current-branch] [target-repository]"
  echo
  echo "Options:"
  echo "  --merge                 Preserve existing coding-agent configuration for semantic migration."
  echo "  --allow-current-branch  Allow installation on the repository's default branch."
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

MERGE_MODE=0
ALLOW_CURRENT_BRANCH=0
TARGET_ARGUMENT=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --merge)
      MERGE_MODE=1
      ;;
    --allow-current-branch)
      ALLOW_CURRENT_BRANCH=1
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

  if [ "$status" -ne 0 ]; then
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

if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "error: target is not a Git repository: $TARGET_DIR" >&2
  echo "Initialize Git first with: git init" >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "error: Git is required to inspect the target repository" >&2
  exit 1
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
      echo "error: refusing to install on the repository's default branch: $CURRENT_BRANCH" >&2
      echo "Create a focused branch first:" >&2
      echo "  git switch -c chore/coding-agent-bootstrap" >&2
      echo "Or re-run with --allow-current-branch if this is intentional." >&2
      exit 1
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

if [ "$HAS_EXISTING" -eq 1 ] && [ "$MERGE_MODE" -eq 0 ]; then
  echo "Existing coding-agent configuration detected:" >&2
  [ "$EXISTING_AGENTS_MD" -eq 0 ] || echo "  AGENTS.md" >&2
  [ "$EXISTING_CLAUDE_MD" -eq 0 ] || echo "  CLAUDE.md" >&2
  [ "$EXISTING_AGENTS_DIR" -eq 0 ] || echo "  .agents/" >&2
  echo >&2
  echo "Refusing to overwrite existing configuration." >&2
  echo "Re-run with --merge to preserve and migrate the existing configuration." >&2
  exit 1
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

echo "Installed coding-agent-bootstrap into:"
echo "  $TARGET_DIR"
if [ "$HAS_EXISTING" -eq 1 ]; then
  echo
  echo "Existing coding-agent configuration was preserved at:"
  echo "  .coding-agent-bootstrap/existing/"
fi
echo
echo "Next: start a coding-agent session in the target repository."
echo "The agent should read AGENTS.md and complete .agents/BOOTSTRAP.md before normal project work."
