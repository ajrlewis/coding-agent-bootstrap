#!/bin/sh
set -eu

usage() {
  echo "Usage: ./install.sh [target-repository]" >&2
  echo "Copies coding-agent-bootstrap files into the target repository." >&2
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TARGET_DIR=${1:-$(pwd)}

if [ ! -d "$TARGET_DIR" ]; then
  echo "error: target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

TARGET_DIR=$(CDPATH= cd -- "$TARGET_DIR" && pwd)

if [ "$SOURCE_DIR" = "$TARGET_DIR" ]; then
  echo "error: source and target are the same directory" >&2
  echo "Clone this bootstrap repository elsewhere, then run install.sh with your project path." >&2
  exit 1
fi

if [ ! -d "$TARGET_DIR/.git" ]; then
  echo "error: target is not a Git repository: $TARGET_DIR" >&2
  echo "Initialize Git first with: git init" >&2
  exit 1
fi

for path in AGENTS.md CLAUDE.md .agents; do
  if [ -e "$TARGET_DIR/$path" ]; then
    echo "error: refusing to overwrite existing $path in target repository" >&2
    exit 1
  fi
done

if [ ! -f "$SOURCE_DIR/AGENTS.md" ] || [ ! -d "$SOURCE_DIR/.agents" ]; then
  echo "error: bootstrap source is incomplete" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR/.agents"
cp "$SOURCE_DIR/AGENTS.md" "$TARGET_DIR/AGENTS.md"
cp "$SOURCE_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
cp -R "$SOURCE_DIR/.agents/." "$TARGET_DIR/.agents/"

echo "Installed coding-agent-bootstrap into:"
echo "  $TARGET_DIR"
echo
echo "Next: start a coding-agent session in the target repository."
echo "The agent should read AGENTS.md, complete .agents/BOOTSTRAP.md, keep only project-relevant context, and remove .agents/BOOTSTRAP.md after setup."
