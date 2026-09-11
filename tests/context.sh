#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

require_file() {
  [ -f "$1" ] || fail "required file is missing: $1"
}

require_text() {
  grep -F "$2" "$1" >/dev/null || fail "$1 does not contain: $2"
}

for path in \
  AGENTS.md \
  CLAUDE.md \
  .agents/ARCHITECTURE.md \
  .agents/COMMANDS.md \
  .agents/DOCTOR.md \
  .agents/WORKFLOW.md \
  .agents/todos/TODO.md \
  .agents/todos/DONE.md \
  bootstrap/AGENTS.md \
  bootstrap/CLAUDE.md \
  bootstrap/.agents/ARCHITECTURE.md \
  bootstrap/.agents/BOOTSTRAP.md \
  bootstrap/.agents/COMMANDS.md \
  bootstrap/.agents/DOCTOR.md \
  bootstrap/.agents/WORKFLOW.md \
  bootstrap/.agents/todos/TODO.md \
  bootstrap/.agents/todos/DONE.md \
  bootstrap/.agents/presets/architecture/monorepo.md \
  bootstrap/.agents/presets/ci/azure-pipelines.md \
  bootstrap/.agents/presets/database/snowflake.md \
  bootstrap/.agents/presets/database/sql-server.md \
  bootstrap/.agents/presets/git/github-flow.md \
  bootstrap/.agents/presets/git/azure-devops.md \
  bootstrap/.agents/presets/infrastructure/bicep.md \
  bootstrap/.agents/presets/observability/logging.md \
  bootstrap/.agents/presets/quality/api-documentation.md \
  bootstrap/.agents/presets/quality/testing.md \
  bootstrap/.agents/presets/tooling/turborepo.md
do
  require_file "$path"
done

for route in \
  '.agents/WORKFLOW.md' \
  '.agents/COMMANDS.md' \
  '.agents/ARCHITECTURE.md' \
  '.agents/DOCTOR.md' \
  '.agents/todos/TODO.md' \
  '.agents/todos/DONE.md'
do
  require_text AGENTS.md "$route"
  require_text bootstrap/AGENTS.md "$route"
done

bootstrap_route='If `.agents/BOOTSTRAP.md` exists'
if grep -F "$bootstrap_route" AGENTS.md >/dev/null; then
  fail "root AGENTS.md retains the payload-only bootstrap route"
fi
require_text bootstrap/AGENTS.md "$bootstrap_route"

legacy_todo_path='.agents/TODO.md'
if grep -R -F "$legacy_todo_path" AGENTS.md README.md .agents bootstrap >/dev/null; then
  fail "agent context contains the legacy TODO path"
fi
[ ! -e .agents/TODO.md ] || fail "root legacy TODO file exists"
[ ! -e bootstrap/.agents/TODO.md ] || fail "payload legacy TODO file exists"

[ "$(sed -n '1p' .agents/VERSION)" = "2" ] || fail "root agent-context version is not 2"
[ "$(sed -n '1p' bootstrap/.agents/VERSION)" = "4" ] || fail "payload version is not 4"

cmp .agents/DOCTOR.md bootstrap/.agents/DOCTOR.md >/dev/null || fail "root and payload doctor procedures differ"
if cmp .agents/ARCHITECTURE.md bootstrap/.agents/ARCHITECTURE.md >/dev/null; then
  fail "root development architecture matches the target payload"
fi

empty_directories=$(find .agents bootstrap/.agents -type d -empty -print)
if [ -n "$empty_directories" ]; then
  echo "$empty_directories" >&2
  fail "agent context contains empty directories"
fi

echo "Agent context checks passed."
