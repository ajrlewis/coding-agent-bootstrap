#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEST_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/coding-agent-bootstrap-tests.XXXXXX")

cleanup() {
  status=$?
  trap - EXIT HUP INT TERM
  rm -rf "$TEST_ROOT"
  exit "$status"
}

trap cleanup EXIT
trap 'exit 1' HUP INT TERM

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

make_git_repo() {
  TEST_REPO=$TEST_ROOT/$1
  mkdir -p "$TEST_REPO"
  git -C "$TEST_REPO" init --quiet
}

assert_failed_with() {
  expected=$1
  shift
  output_file=$TEST_ROOT/failure-output
  if "$@" >"$output_file" 2>&1; then
    fail "command unexpectedly succeeded: $*"
  fi
  if ! grep -F "$expected" "$output_file" >/dev/null; then
    echo "Expected failure containing: $expected" >&2
    sed -n '1,120p' "$output_file" >&2
    fail "unexpected error message"
  fi
}

assert_no_staging_files() {
  target=$1
  if find "$target" -maxdepth 1 -name '.coding-agent-bootstrap.*' -print | grep . >/dev/null; then
    fail "installer left staging files in $target"
  fi
}

echo "Testing local installation..."
make_git_repo local-target
"$ROOT_DIR/install.sh" "$TEST_REPO" >/dev/null
[ -f "$TEST_REPO/AGENTS.md" ] || fail "AGENTS.md was not installed"
[ -f "$TEST_REPO/CLAUDE.md" ] || fail "CLAUDE.md was not installed"
[ -f "$TEST_REPO/.agents/BOOTSTRAP.md" ] || fail "BOOTSTRAP.md was not installed"
[ "$(sed -n '1p' "$TEST_REPO/.agents/VERSION")" = "2" ] || fail "payload version is not 2"
cmp "$ROOT_DIR/bootstrap/AGENTS.md" "$TEST_REPO/AGENTS.md" >/dev/null || fail "installed AGENTS.md does not match payload"
cmp "$ROOT_DIR/bootstrap/.agents/ARCHITECTURE.md" "$TEST_REPO/.agents/ARCHITECTURE.md" >/dev/null || fail "installed architecture does not match payload"
if cmp "$ROOT_DIR/.agents/ARCHITECTURE.md" "$TEST_REPO/.agents/ARCHITECTURE.md" >/dev/null; then
  fail "root development architecture leaked into target"
fi
assert_no_staging_files "$TEST_REPO"

echo "Testing overwrite refusal..."
make_git_repo existing-agents-md
printf '%s\n' "existing" >"$TEST_REPO/AGENTS.md"
assert_failed_with "refusing to overwrite existing AGENTS.md" "$ROOT_DIR/install.sh" "$TEST_REPO"
[ "$(sed -n '1p' "$TEST_REPO/AGENTS.md")" = "existing" ] || fail "existing AGENTS.md changed"

make_git_repo existing-agents-dir
mkdir "$TEST_REPO/.agents"
printf '%s\n' "existing" >"$TEST_REPO/.agents/keep"
assert_failed_with "refusing to overwrite existing .agents" "$ROOT_DIR/install.sh" "$TEST_REPO"
[ -f "$TEST_REPO/.agents/keep" ] || fail "existing .agents content changed"

echo "Testing Git repository requirement..."
mkdir "$TEST_ROOT/not-git"
assert_failed_with "target is not a Git repository" "$ROOT_DIR/install.sh" "$TEST_ROOT/not-git"

echo "Testing source/target refusal..."
assert_failed_with "source and target are the same directory" "$ROOT_DIR/install.sh" "$ROOT_DIR"

echo "Testing remote-style installation..."
REMOTE_SOURCE=$TEST_ROOT/remote-source
mkdir "$REMOTE_SOURCE"
cp "$ROOT_DIR/install.sh" "$REMOTE_SOURCE/install.sh"
cp -R "$ROOT_DIR/bootstrap" "$REMOTE_SOURCE/bootstrap"
git -C "$REMOTE_SOURCE" init --quiet --initial-branch=main
git -C "$REMOTE_SOURCE" config user.name "Installer Test"
git -C "$REMOTE_SOURCE" config user.email "installer-test@example.invalid"
git -C "$REMOTE_SOURCE" add install.sh bootstrap
git -C "$REMOTE_SOURCE" commit --quiet -m "Test fixture"

make_git_repo remote-target
REMOTE_TARGET=$TEST_REPO
DOWNLOAD_ROOT=$TEST_ROOT/downloads
mkdir "$DOWNLOAD_ROOT"
(
  cd "$REMOTE_TARGET"
  TMPDIR=$DOWNLOAD_ROOT \
    CAB_INSTALL_REPOSITORY="file://$REMOTE_SOURCE" \
    CAB_INSTALL_REF=main \
    sh <"$ROOT_DIR/install.sh" >/dev/null
)

cmp "$ROOT_DIR/bootstrap/AGENTS.md" "$REMOTE_TARGET/AGENTS.md" >/dev/null || fail "remote-style AGENTS.md does not match payload"
[ -f "$REMOTE_TARGET/.agents/BOOTSTRAP.md" ] || fail "remote-style install omitted BOOTSTRAP.md"
assert_no_staging_files "$REMOTE_TARGET"
download_leftovers=$(find "$DOWNLOAD_ROOT" -maxdepth 1 -name 'coding-agent-bootstrap.*' -print)
if [ -n "$download_leftovers" ]; then
  echo "$download_leftovers" >&2
  fail "remote-style installer did not clean its download directory"
fi

echo "All installer tests passed."
