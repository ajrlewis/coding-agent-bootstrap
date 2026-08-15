#!/bin/sh
set -eu

REPOSITORY_URL=${CAB_INSTALL_REPOSITORY:-https://github.com/ajrlewis/coding-agent-bootstrap.git}
REPOSITORY_REF=${CAB_INSTALL_REF:-main}

usage() {
  echo "Usage: install.sh [target-repository]" >&2
  echo "Installs the bootstrap payload into a target Git repository." >&2
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

TARGET_DIR=${1:-$(pwd)}
DOWNLOAD_DIR=
STAGE_DIR=
INSTALLED_AGENTS_MD=0
INSTALLED_CLAUDE_MD=0
INSTALLED_AGENTS_DIR=0

cleanup() {
  status=$?
  trap - EXIT HUP INT TERM

  if [ "$status" -ne 0 ]; then
    [ "$INSTALLED_AGENTS_MD" -eq 0 ] || rm -f "$TARGET_DIR/AGENTS.md"
    [ "$INSTALLED_CLAUDE_MD" -eq 0 ] || rm -f "$TARGET_DIR/CLAUDE.md"
    [ "$INSTALLED_AGENTS_DIR" -eq 0 ] || rm -rf "$TARGET_DIR/.agents"
  fi

  [ -z "$STAGE_DIR" ] || [ ! -d "$STAGE_DIR" ] || rm -rf "$STAGE_DIR"
  [ -z "$DOWNLOAD_DIR" ] || [ ! -d "$DOWNLOAD_DIR" ] || rm -rf "$DOWNLOAD_DIR"
  exit "$status"
}

trap cleanup EXIT
trap 'exit 1' HUP INT TERM

if [ ! -d "$TARGET_DIR" ]; then
  echo "error: target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

TARGET_DIR=$(CDPATH= cd -- "$TARGET_DIR" && pwd)

if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "error: target is not a Git repository: $TARGET_DIR" >&2
  echo "Initialize Git first with: git init" >&2
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

for path in AGENTS.md CLAUDE.md .agents; do
  if [ -e "$TARGET_DIR/$path" ]; then
    echo "error: refusing to overwrite existing $path in target repository" >&2
    exit 1
  fi
done

if [ -n "$SOURCE_DIR" ] && [ -f "$SOURCE_DIR/bootstrap/AGENTS.md" ] && [ -d "$SOURCE_DIR/bootstrap/.agents" ]; then
  PAYLOAD_DIR=$SOURCE_DIR/bootstrap
else
  if ! command -v git >/dev/null 2>&1; then
    echo "error: Git is required to fetch the bootstrap payload" >&2
    exit 1
  fi

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

STAGE_DIR=$(mktemp -d "$TARGET_DIR/.coding-agent-bootstrap.XXXXXX")
mkdir "$STAGE_DIR/.agents"
cp "$PAYLOAD_DIR/AGENTS.md" "$STAGE_DIR/AGENTS.md"
cp "$PAYLOAD_DIR/CLAUDE.md" "$STAGE_DIR/CLAUDE.md"
cp -R "$PAYLOAD_DIR/.agents/." "$STAGE_DIR/.agents/"

mv "$STAGE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
INSTALLED_AGENTS_MD=1
mv "$STAGE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
INSTALLED_CLAUDE_MD=1
mv "$STAGE_DIR/.agents" "$TARGET_DIR/.agents"
INSTALLED_AGENTS_DIR=1

echo "Installed coding-agent-bootstrap into:"
echo "  $TARGET_DIR"
echo
echo "Next: start a coding-agent session in the target repository."
echo "The agent should read AGENTS.md and complete .agents/BOOTSTRAP.md before normal project work."
