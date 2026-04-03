# Phase 2: Model Matrix

Run the same A/B test across multiple Claude models to see how architectural knowledge benefits vary by model capability.

## Models

| Model | Claude Code ID | Notes |
|---|---|---|
| Opus | claude-opus-4-6 | Most capable, highest cost |
| Sonnet | claude-sonnet-4-6 | Balanced capability/cost |
| Haiku | claude-haiku-4-5-20251001 | Fastest, lowest cost |

## How to Switch Models

In Claude Code, use the `/model` command before starting a run:

```
/model opus
/model sonnet
/model haiku
```

## Run Matrix

Each cell = one run minimum. 3 runs per cell recommended for meaningful signal.

| Model | Baseline | With Context |
|---|---|---|
| Opus | [ ] 1 run / [ ] 2 runs / [ ] 3 runs | [ ] 1 run / [ ] 2 runs / [ ] 3 runs |
| Sonnet | [ ] 1 run / [ ] 2 runs / [ ] 3 runs | [ ] 1 run / [ ] 2 runs / [ ] 3 runs |
| Haiku | [ ] 1 run / [ ] 2 runs / [ ] 3 runs | [ ] 1 run / [ ] 2 runs / [ ] 3 runs |

## Running a Cell

1. Run `setup.sh` if you haven't already (only needed once per commit)
2. Open the appropriate worktree: `cd /tmp/ddev-ab-<condition>-<sha>/`
3. Start Claude Code: `claude`
4. Switch model: `/model <model-name>`
5. Paste prompt from `task-prompt.md`
6. When done, score: `./docs/experiments/codified-context-ab/score.sh /tmp/ddev-ab-<condition>-<sha>/`
7. Record results: copy `results/TEMPLATE.md` to `results/<date>-<model>-<condition>.md`
8. **Reset the worktree** before the next run in the same condition:
   ```bash
   cd /tmp/ddev-ab-<condition>-<sha>/
   git checkout -- .
   git clean -fd
   ```

## Comparison Table

After completing runs, fill in this table:

| Model | Baseline (avg/7) | With Context (avg/7) | Delta | Notes |
|---|---|---|---|---|
| Opus | | | | |
| Sonnet | | | | |
| Haiku | | | | |

## What to Look For

- **Capability floor:** Does codified context help weaker models more than stronger ones? (Hypothesis: Haiku benefits most.)
- **Diminishing returns:** Does Opus already get most criteria right without context, making the delta smaller?
- **Failure modes:** Do different models fail on different criteria? Does codified context shift which criteria they get right?
- **Cost efficiency:** If Sonnet + context scores as well as Opus without context, that's a cost argument for codified context.
