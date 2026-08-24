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

make_committed_git_repo() {
  TEST_REPO=$TEST_ROOT/$1
  mkdir -p "$TEST_REPO"
  git -C "$TEST_REPO" init --quiet --initial-branch=main
  git -C "$TEST_REPO" config user.name "Installer Test"
  git -C "$TEST_REPO" config user.email "installer-test@example.invalid"
  printf '%s\n' "tracked fixture" >"$TEST_REPO/tracked.txt"
  git -C "$TEST_REPO" add tracked.txt
  git -C "$TEST_REPO" commit --quiet -m "Initial fixture"
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
  if find "$target" -maxdepth 1 -name '.coding-agent-bootstrap-stage.*' -print | grep . >/dev/null; then
    fail "installer left staging files in $target"
  fi
}

echo "Testing local installation..."
"$ROOT_DIR/install.sh" --help >"$TEST_ROOT/help-output"
grep -F "install.sh [--merge] [--allow-current-branch] [target-repository]" "$TEST_ROOT/help-output" >/dev/null || fail "help omits installer options"
make_git_repo local-target
"$ROOT_DIR/install.sh" "$TEST_REPO" >/dev/null
[ -f "$TEST_REPO/AGENTS.md" ] || fail "AGENTS.md was not installed"
[ -f "$TEST_REPO/CLAUDE.md" ] || fail "CLAUDE.md was not installed"
[ -f "$TEST_REPO/.agents/BOOTSTRAP.md" ] || fail "BOOTSTRAP.md was not installed"
[ -f "$TEST_REPO/.agents/mcp/linear.md" ] || fail "Linear MCP capability was not installed"
[ "$(sed -n '1p' "$TEST_REPO/.agents/VERSION")" = "3" ] || fail "payload version is not 3"
cmp "$ROOT_DIR/bootstrap/AGENTS.md" "$TEST_REPO/AGENTS.md" >/dev/null || fail "installed AGENTS.md does not match payload"
cmp "$ROOT_DIR/bootstrap/.agents/ARCHITECTURE.md" "$TEST_REPO/.agents/ARCHITECTURE.md" >/dev/null || fail "installed architecture does not match payload"
if cmp "$ROOT_DIR/.agents/ARCHITECTURE.md" "$TEST_REPO/.agents/ARCHITECTURE.md" >/dev/null; then
  fail "root development architecture leaked into target"
fi
assert_no_staging_files "$TEST_REPO"
[ ! -e "$TEST_REPO/.coding-agent-bootstrap" ] || fail "clean install created migration state"

echo "Testing default-branch refusal..."
make_committed_git_repo default-branch
assert_failed_with "refusing to install on the repository's default branch: main" "$ROOT_DIR/install.sh" "$TEST_REPO"
[ ! -e "$TEST_REPO/AGENTS.md" ] || fail "default-branch refusal installed AGENTS.md"
[ ! -e "$TEST_REPO/.agents" ] || fail "default-branch refusal installed .agents"

make_committed_git_repo remote-default-branch
git -C "$TEST_REPO" branch -m trunk
git -C "$TEST_REPO" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/trunk
assert_failed_with "refusing to install on the repository's default branch: trunk" "$ROOT_DIR/install.sh" "$TEST_REPO"

make_committed_git_repo allowed-default-branch
"$ROOT_DIR/install.sh" --allow-current-branch "$TEST_REPO" >/dev/null
[ -f "$TEST_REPO/.agents/BOOTSTRAP.md" ] || fail "default-branch override did not install payload"

make_committed_git_repo feature-branch
git -C "$TEST_REPO" switch --quiet -c chore/bootstrap-test
"$ROOT_DIR/install.sh" "$TEST_REPO" >/dev/null
[ -f "$TEST_REPO/.agents/BOOTSTRAP.md" ] || fail "feature-branch install did not install payload"

echo "Testing overwrite refusal..."
make_git_repo existing-agents-md
printf '%s\n' "existing" >"$TEST_REPO/AGENTS.md"
assert_failed_with "Re-run with --merge" "$ROOT_DIR/install.sh" "$TEST_REPO"
[ "$(sed -n '1p' "$TEST_REPO/AGENTS.md")" = "existing" ] || fail "existing AGENTS.md changed"

make_git_repo existing-agents-dir
mkdir "$TEST_REPO/.agents"
printf '%s\n' "existing" >"$TEST_REPO/.agents/keep"
assert_failed_with "Re-run with --merge" "$ROOT_DIR/install.sh" "$TEST_REPO"
[ -f "$TEST_REPO/.agents/keep" ] || fail "existing .agents content changed"

echo "Testing full merge preservation..."
make_git_repo full-merge
printf '%s' "existing agents without trailing newline" >"$TEST_REPO/AGENTS.md"
printf '%s\n' "existing claude" >"$TEST_REPO/CLAUDE.md"
mkdir -p "$TEST_REPO/.agents/nested"
printf '%s\n' "existing workflow" >"$TEST_REPO/.agents/WORKFLOW.md"
printf '%s' "nested bytes" >"$TEST_REPO/.agents/nested/context.md"
printf '%s\n' "hidden context" >"$TEST_REPO/.agents/.hidden"
EXPECTED_FULL=$TEST_ROOT/expected-full
mkdir -p "$EXPECTED_FULL"
cp -p "$TEST_REPO/AGENTS.md" "$EXPECTED_FULL/AGENTS.md"
cp -p "$TEST_REPO/CLAUDE.md" "$EXPECTED_FULL/CLAUDE.md"
cp -Rp "$TEST_REPO/.agents" "$EXPECTED_FULL/.agents"

"$ROOT_DIR/install.sh" --merge "$TEST_REPO" >/dev/null
cmp "$EXPECTED_FULL/AGENTS.md" "$TEST_REPO/.coding-agent-bootstrap/existing/AGENTS.md" >/dev/null || fail "AGENTS.md was not preserved byte-for-byte"
cmp "$EXPECTED_FULL/CLAUDE.md" "$TEST_REPO/.coding-agent-bootstrap/existing/CLAUDE.md" >/dev/null || fail "CLAUDE.md was not preserved byte-for-byte"
cmp "$EXPECTED_FULL/.agents/WORKFLOW.md" "$TEST_REPO/.coding-agent-bootstrap/existing/.agents/WORKFLOW.md" >/dev/null || fail "existing .agents file changed"
cmp "$EXPECTED_FULL/.agents/nested/context.md" "$TEST_REPO/.coding-agent-bootstrap/existing/.agents/nested/context.md" >/dev/null || fail "nested .agents content changed"
cmp "$EXPECTED_FULL/.agents/.hidden" "$TEST_REPO/.coding-agent-bootstrap/existing/.agents/.hidden" >/dev/null || fail "hidden .agents content changed"
cmp "$ROOT_DIR/bootstrap/AGENTS.md" "$TEST_REPO/AGENTS.md" >/dev/null || fail "merge did not install payload AGENTS.md"
cmp "$ROOT_DIR/bootstrap/.agents/WORKFLOW.md" "$TEST_REPO/.agents/WORKFLOW.md" >/dev/null || fail "merge did not install payload .agents"
assert_no_staging_files "$TEST_REPO"

echo "Testing rollback after preservation..."
make_git_repo rollback-merge
printf '%s\n' "restore after installer failure" >"$TEST_REPO/AGENTS.md"
cp -p "$TEST_REPO/AGENTS.md" "$TEST_ROOT/rollback-agents-expected"
FAKE_BIN=$TEST_ROOT/fake-bin
mkdir "$FAKE_BIN"
printf '%s\n' \
  '#!/bin/sh' \
  'case "$1" in' \
  '  */payload/AGENTS.md) exit 42 ;;' \
  'esac' \
  'exec "$CAB_TEST_REAL_MV" "$@"' >"$FAKE_BIN/mv"
chmod +x "$FAKE_BIN/mv"
REAL_MV=$(command -v mv)
failure_output=$TEST_ROOT/rollback-output
if PATH="$FAKE_BIN:$PATH" CAB_TEST_REAL_MV="$REAL_MV" "$ROOT_DIR/install.sh" --merge "$TEST_REPO" >"$failure_output" 2>&1; then
  fail "injected post-preservation failure unexpectedly succeeded"
fi
cmp "$TEST_ROOT/rollback-agents-expected" "$TEST_REPO/AGENTS.md" >/dev/null || fail "rollback did not restore existing AGENTS.md"
[ ! -e "$TEST_REPO/CLAUDE.md" ] || fail "rollback left payload CLAUDE.md"
[ ! -e "$TEST_REPO/.agents" ] || fail "rollback left payload .agents"
[ ! -e "$TEST_REPO/.coding-agent-bootstrap" ] || fail "successful rollback left migration state"
assert_no_staging_files "$TEST_REPO"

echo "Testing partial merge preservation..."
make_git_repo partial-merge
printf '%s\n' "only existing agents" >"$TEST_REPO/AGENTS.md"
cp -p "$TEST_REPO/AGENTS.md" "$TEST_ROOT/partial-agents-expected"
"$ROOT_DIR/install.sh" "$TEST_REPO" --merge >/dev/null
cmp "$TEST_ROOT/partial-agents-expected" "$TEST_REPO/.coding-agent-bootstrap/existing/AGENTS.md" >/dev/null || fail "partial AGENTS.md was not preserved"
[ ! -e "$TEST_REPO/.coding-agent-bootstrap/existing/CLAUDE.md" ] || fail "merge preserved a nonexistent CLAUDE.md"
[ ! -e "$TEST_REPO/.coding-agent-bootstrap/existing/.agents" ] || fail "merge preserved a nonexistent .agents"
[ -f "$TEST_REPO/CLAUDE.md" ] || fail "partial merge did not install payload CLAUDE.md"
[ -f "$TEST_REPO/.agents/BOOTSTRAP.md" ] || fail "partial merge did not install bootstrap state"
assert_no_staging_files "$TEST_REPO"

echo "Testing existing migration-state refusal..."
make_git_repo existing-migration-state
mkdir -p "$TEST_REPO/.coding-agent-bootstrap/existing"
printf '%s\n' "preserved" >"$TEST_REPO/.coding-agent-bootstrap/existing/AGENTS.md"
assert_failed_with "temporary migration state already exists" "$ROOT_DIR/install.sh" --merge "$TEST_REPO"
[ -f "$TEST_REPO/.coding-agent-bootstrap/existing/AGENTS.md" ] || fail "existing migration state changed"

echo "Testing Git repository requirement..."
mkdir "$TEST_ROOT/not-git"
assert_failed_with "target is not a Git repository" "$ROOT_DIR/install.sh" "$TEST_ROOT/not-git"

echo "Testing source/target refusal..."
assert_failed_with "source and target are the same directory" "$ROOT_DIR/install.sh" "$ROOT_DIR"

echo "Testing remote-style merge installation..."
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
printf '%s\n' "remote existing agents" >"$REMOTE_TARGET/AGENTS.md"
cp -p "$REMOTE_TARGET/AGENTS.md" "$TEST_ROOT/remote-agents-expected"
DOWNLOAD_ROOT=$TEST_ROOT/downloads
mkdir "$DOWNLOAD_ROOT"
(
  cd "$REMOTE_TARGET"
  TMPDIR=$DOWNLOAD_ROOT \
    CAB_INSTALL_REPOSITORY="file://$REMOTE_SOURCE" \
    CAB_INSTALL_REF=main \
    sh -s -- --merge <"$ROOT_DIR/install.sh" >/dev/null
)

cmp "$ROOT_DIR/bootstrap/AGENTS.md" "$REMOTE_TARGET/AGENTS.md" >/dev/null || fail "remote-style AGENTS.md does not match payload"
[ -f "$REMOTE_TARGET/.agents/BOOTSTRAP.md" ] || fail "remote-style install omitted BOOTSTRAP.md"
cmp "$TEST_ROOT/remote-agents-expected" "$REMOTE_TARGET/.coding-agent-bootstrap/existing/AGENTS.md" >/dev/null || fail "remote-style merge did not preserve AGENTS.md"
assert_no_staging_files "$REMOTE_TARGET"
download_leftovers=$(find "$DOWNLOAD_ROOT" -maxdepth 1 -name 'coding-agent-bootstrap.*' -print)
if [ -n "$download_leftovers" ]; then
  echo "$download_leftovers" >&2
  fail "remote-style installer did not clean its download directory"
fi

echo "Testing failed merge preservation..."
git -C "$REMOTE_SOURCE" checkout --quiet -b incomplete
rm "$REMOTE_SOURCE/bootstrap/.agents/BOOTSTRAP.md"
git -C "$REMOTE_SOURCE" add bootstrap/.agents/BOOTSTRAP.md
git -C "$REMOTE_SOURCE" commit --quiet -m "Incomplete payload"
make_git_repo failed-merge
FAILED_TARGET=$TEST_REPO
printf '%s\n' "must survive failed merge" >"$FAILED_TARGET/AGENTS.md"
cp -p "$FAILED_TARGET/AGENTS.md" "$TEST_ROOT/failed-agents-expected"
failure_output=$TEST_ROOT/failed-merge-output
if (
  cd "$FAILED_TARGET"
  TMPDIR=$DOWNLOAD_ROOT \
    CAB_INSTALL_REPOSITORY="file://$REMOTE_SOURCE" \
    CAB_INSTALL_REF=incomplete \
    sh -s -- --merge <"$ROOT_DIR/install.sh"
) >"$failure_output" 2>&1; then
  fail "merge with incomplete payload unexpectedly succeeded"
fi
grep -F "bootstrap payload is incomplete" "$failure_output" >/dev/null || fail "failed merge reported the wrong error"
cmp "$TEST_ROOT/failed-agents-expected" "$FAILED_TARGET/AGENTS.md" >/dev/null || fail "failed merge changed existing AGENTS.md"
[ ! -e "$FAILED_TARGET/.coding-agent-bootstrap" ] || fail "failed merge left migration state"
[ ! -e "$FAILED_TARGET/.agents" ] || fail "failed merge installed partial payload"
assert_no_staging_files "$FAILED_TARGET"

echo "All installer tests passed."
