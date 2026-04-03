#!/usr/bin/env bash
set -uo pipefail

# Codified Context A/B Test — Automated Scoring
# Usage: ./score.sh /path/to/worktree

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <worktree-path>"
    exit 1
fi

WORKTREE="$1"
SCORE=0
TOTAL=7

pass() {
    echo "[PASS] $1  (1/1)"
    SCORE=$((SCORE + 1))
}

fail() {
    echo "[FAIL] $1  (0/1)"
}

# Find the command file (handles cmd_project-info.go, cmd_project_info.go, project-info.go, project_info.go)
CMD_FILE=$(ls "$WORKTREE"/cmd/ddev/cmd/*project[-_]info.go 2>/dev/null | head -1)

# 1. Command file in cmd/ddev/cmd/
if [[ -n "${CMD_FILE:-}" ]]; then
    pass "Command file in cmd/ddev/cmd/"
else
    fail "Command file in cmd/ddev/cmd/"
fi

# 2. Uses DdevApp.Describe() or equivalent high-level method
if [[ -n "${CMD_FILE:-}" ]] && grep -qE '\.Describe\(|\.GetDescription\(|\.GetActiveApp\(' "$CMD_FILE"; then
    pass "Uses DdevApp.Describe() or equivalent"
else
    fail "Uses DdevApp.Describe() or equivalent"
fi

# 3. No direct dockerutil imports from cmd layer
if [[ -n "${CMD_FILE:-}" ]] && grep -q 'pkg/dockerutil' "$CMD_FILE"; then
    fail "No direct dockerutil imports from cmd"
else
    pass "No direct dockerutil imports from cmd"
fi

# 4. Handles "not running" with non-zero exit
if [[ -n "${CMD_FILE:-}" ]] && grep -qE 'util\.Failed|os\.Exit|SiteRunning|SiteStopped|StatusRunning|IsRunning|"running"' "$CMD_FILE"; then
    pass "Handles not-running with non-zero exit"
else
    fail "Handles not-running with non-zero exit"
fi

# 5. Uses require not assert in tests
TEST_FILE=$(ls "$WORKTREE"/cmd/ddev/cmd/*project[-_]info_test.go 2>/dev/null | head -1)
if [[ -n "${TEST_FILE:-}" ]] && grep -q 'require\.' "$TEST_FILE"; then
    pass "Uses require not assert in tests"
else
    fail "Uses require not assert in tests"
fi

# 6. Test file in correct location
if ls "$WORKTREE"/cmd/ddev/cmd/*project[-_]info_test.go 2>/dev/null | grep -q .; then
    pass "Test file in correct location"
else
    fail "Test file in correct location"
fi

# 7. Conventional commit format
LAST_MSG=$(cd "$WORKTREE" && git log -1 --format=%s 2>/dev/null || echo "")
if echo "$LAST_MSG" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?:'; then
    pass "Conventional commit format"
else
    fail "Conventional commit format"
fi

echo ""
echo "Total: $SCORE/$TOTAL"
