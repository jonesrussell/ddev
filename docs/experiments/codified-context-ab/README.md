# Codified Context A/B Test

An experiment measuring whether machine-readable subsystem specs improve AI agent performance on architectural tasks in the DDEV codebase.

## Quick Start

```bash
# 1. Run setup (creates two worktrees in /tmp/)
./setup.sh

# 2. Open baseline worktree in Claude Code
cd /tmp/ddev-ab-baseline-<sha>/
claude

# 3. Paste the prompt from task-prompt.md, let the agent work

# 4. Score the result
cd /path/to/ddev
./docs/experiments/codified-context-ab/score.sh /tmp/ddev-ab-baseline-<sha>/

# 5. Repeat steps 2-4 with the with-context worktree
cd /tmp/ddev-ab-with-context-<sha>/
claude

# 6. Score
./docs/experiments/codified-context-ab/score.sh /tmp/ddev-ab-with-context-<sha>/

# 7. Record results using results/TEMPLATE.md
```

## Prerequisites

- Git with worktree support
- Claude Code CLI installed
- A clone of jonesrussell/ddev (or ddev/ddev with codified-context specs)

## What setup.sh Does

Creates two git worktrees from the current HEAD:

**Baseline** (`/tmp/ddev-ab-baseline-<sha>/`):
- CLAUDE.md with the "Orchestration (Codified Context)" and "Layer Reference" sections removed
- No `docs/codified-context/` directory
- No codified context routing skills
- Everything else identical

**With Context** (`/tmp/ddev-ab-with-context-<sha>/`):
- Full CLAUDE.md including orchestration table and layer reference
- Codified context specs in `docs/codified-context/`
- Routing skills in `docs/codified-context/skills/`
- Everything else identical

## The Task

Both conditions receive the same prompt (see `task-prompt.md`). The task is designed to cross all four architectural layers and require knowledge of subsystem boundaries and available methods.

## Scoring

`score.sh` runs 7 automated checks (see `answer-key.md` for details):

1. Command file placed in `cmd/ddev/cmd/`
2. Uses `DdevApp.Describe()` or equivalent high-level method
3. No direct dockerutil imports from the cmd layer
4. Handles "not running" with non-zero exit code
5. Uses `require` (not `assert`) in tests
6. Test file in correct location
7. Conventional commit format

Plus qualitative metrics recorded manually in each result file.

## Recording Results

Copy `results/TEMPLATE.md` for each run. Name it `<date>-<model>-<condition>.md`.

## Phase 2: Model Matrix

See `phase2/model-matrix.md` for instructions on running across Opus, Sonnet, and Haiku.

## Cleanup

```bash
# Remove worktrees when done
git worktree remove /tmp/ddev-ab-baseline-<sha>/ 2>/dev/null
git worktree remove /tmp/ddev-ab-with-context-<sha>/ 2>/dev/null
```
