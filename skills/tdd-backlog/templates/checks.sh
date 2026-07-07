#!/usr/bin/env bash
# Repo gate — 0 failures required before "done".
#   bash backlog/checks.sh              # fast inner loop
#   CHECKS_FULL=1 bash backlog/checks.sh # + slow tier (build / e2e / packaging)
#
# TEMPLATE: wire the `run` lines below to THIS repo's real commands (read package.json /
# Makefile / justfile / pyproject / Cargo.toml). Pin the test runtime the repo pins
# (.nvmrc / .tool-versions / .python-version). Delete steps that don't apply.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)"

# --- optional: pin test runtime so tests don't run on the wrong version ---
# NVMRC="$(tr -d ' \t\n' < .nvmrc 2>/dev/null)"; N="$HOME/.nvm/versions/node/v$NVMRC"
# [ -d "$N/bin" ] && export PATH="$N/bin:$PATH" && echo "· node $(node -v) (pinned)"

fail=0
run() { local name="$1"; shift; echo "▶ $name"; if "$@"; then echo "  ✓ $name"; else echo "  ✗ FAIL: $name"; fail=$((fail+1)); fi; }

# --- inner loop: fast, run on every task ---  (EDIT THESE)
run "lint"       true   # e.g. pnpm lint | ruff check . | golangci-lint run | cargo clippy
run "typecheck"  true   # e.g. tsc --noEmit | mypy . | (skip for dynamically-typed)
run "unit tests" true   # e.g. pnpm test | pytest -q | go test ./... | cargo test

# --- known-baseline example: fail only on NEW violations, tolerate pre-existing debt ---
# KNOWN=" fileA.ts fileB.ts "
# baseline_check() {
#   local new="" f; for f in $(some-linter --list 2>/dev/null | grep -oE 'src/[^ ]+'); do
#     case "$KNOWN" in *" ${f##*/} "*) ;; *) new="$new $f" ;; esac; done
#   [ -n "$new" ] && { echo "  NEW:$new"; return 1; }; return 0
# }
# run "boundary (new only)" baseline_check

# --- slow tier: only when a boundary / packaging / user-visible flow was touched ---
if [ "${CHECKS_FULL:-0}" = "1" ]; then
  run "build"        true   # e.g. pnpm run build | cargo build --release
  run "e2e / smoke"  true   # e.g. drive the real running app/route/CLI
fi

echo
if [ "$fail" -eq 0 ]; then echo "✓ all checks passed"; else echo "✗ $fail check(s) failed"; exit 1; fi
