#!/usr/bin/env bash
set -euo pipefail

# Codified Context A/B Test — Worktree Setup
# Usage: ./setup.sh
#
# Creates two git worktrees in /tmp/ from the current HEAD:
#   - baseline: CLAUDE.md without orchestration table, no codified-context specs
#   - with-context: full CLAUDE.md, codified-context specs in place
#
# Both worktrees are otherwise identical (same .claude/settings.json, same hooks).

REPO_ROOT="$(git rev-parse --show-toplevel)"
SHA_SHORT="$(git rev-parse --short HEAD)"
SHA_FULL="$(git rev-parse HEAD)"

BASELINE_DIR="/tmp/ddev-ab-baseline-${SHA_SHORT}"
CONTEXT_DIR="/tmp/ddev-ab-with-context-${SHA_SHORT}"
CONTEXT_SPECS_DIR="${REPO_ROOT}/docs/codified-context"

echo "Codified Context A/B Test Setup"
echo "================================"
echo "Commit: ${SHA_FULL}"
echo ""

# Check that codified-context specs exist
if [[ ! -d "$CONTEXT_SPECS_DIR" ]]; then
    echo "ERROR: docs/codified-context/ not found."
    echo "Clone the specs repo first:"
    echo "  git clone git@github.com:jonesrussell/ddev-context.git docs/codified-context"
    exit 1
fi

# Clean up existing worktrees if they exist
for dir in "$BASELINE_DIR" "$CONTEXT_DIR"; do
    if [[ -d "$dir" ]]; then
        echo "Removing existing worktree: $dir"
        git worktree remove "$dir" --force 2>/dev/null || rm -rf "$dir"
    fi
done

# Prune stale worktree references
git worktree prune

echo "Creating baseline worktree..."
git worktree add "$BASELINE_DIR" HEAD --detach --quiet

echo "Creating with-context worktree..."
git worktree add "$CONTEXT_DIR" HEAD --detach --quiet

# --- Baseline: strip codified context ---

# Remove orchestration table and layer reference from CLAUDE.md
# Strips from "### Orchestration (Codified Context)" up to (but not including)
# "### Common Operations"
sed -i '/^### Orchestration (Codified Context)/,/^### Common Operations/{
    /^### Common Operations/!d
}' "$BASELINE_DIR/CLAUDE.md"

# Remove codified-context directory if it exists in the worktree
rm -rf "$BASELINE_DIR/docs/codified-context"

# Remove codified-context skill files if present
if [[ -d "$BASELINE_DIR/.claude/skills" ]]; then
    find "$BASELINE_DIR/.claude/skills/" \
        \( -path "*/ddev-config/*" -o -path "*/ddev-core-app/*" -o -path "*/ddev-docker/*" \) \
        -delete 2>/dev/null || true
    # Clean up empty skill directories
    find "$BASELINE_DIR/.claude/skills/" -type d -empty -delete 2>/dev/null || true
fi

# --- With-context: copy specs into place ---

mkdir -p "$CONTEXT_DIR/docs/codified-context"
rsync -a --exclude='.git' "$CONTEXT_SPECS_DIR/" "$CONTEXT_DIR/docs/codified-context/"

echo ""
echo "Setup complete!"
echo ""
echo "Pinned commit: ${SHA_FULL}"
echo ""
echo "Baseline (no codified context):"
echo "  ${BASELINE_DIR}"
echo ""
echo "With context (codified context specs + orchestration table):"
echo "  ${CONTEXT_DIR}"
echo ""
echo "Next steps:"
echo "  1. Open the baseline worktree in Claude Code:"
echo "     cd ${BASELINE_DIR} && claude"
echo "  2. Paste the prompt from task-prompt.md"
echo "  3. Let the agent complete the task"
echo "  4. Score: ${REPO_ROOT}/docs/experiments/codified-context-ab/score.sh ${BASELINE_DIR}"
echo "  5. Repeat with the with-context worktree:"
echo "     cd ${CONTEXT_DIR} && claude"
echo "  6. Score: ${REPO_ROOT}/docs/experiments/codified-context-ab/score.sh ${CONTEXT_DIR}"
echo "  7. Record results using results/TEMPLATE.md"
