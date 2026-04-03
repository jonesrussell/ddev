# Answer Key: ddev project-info

Scoring criteria for the A/B test task. Each criterion is worth 1 point. Total: 7 points.

## 1. Command file in cmd/ddev/cmd/ (1 point)

**PASS:** A new file exists at `cmd/ddev/cmd/cmd_project-info.go` or `cmd/ddev/cmd/cmd_project_info.go` (either naming convention is acceptable).

**FAIL:** Command logic placed in `pkg/` or elsewhere outside the cmd layer.

## 2. Uses DdevApp.Describe() or equivalent (1 point)

**PASS:** The command calls `app.Describe()`, `app.GetDescription()`, or another high-level method on DdevApp that aggregates project info. The key signal is that it delegates to the app layer rather than assembling data from low-level calls.

**FAIL:** The command directly queries Docker containers, reads config files, or assembles project info from scratch without using DdevApp methods.

## 3. No direct dockerutil imports from cmd layer (1 point)

**PASS:** The new command file does not import `github.com/ddev/ddev/pkg/dockerutil`. It gets container and port information through DdevApp methods.

**FAIL:** The command file has `"github.com/ddev/ddev/pkg/dockerutil"` in its import block.

Check: `grep -l 'pkg/dockerutil' cmd/ddev/cmd/cmd_project*`
Expected: no matches.

## 4. Handles "not running" with non-zero exit (1 point)

**PASS:** The command checks project status before outputting JSON and returns a non-zero exit code (via `os.Exit(1)`, `util.Failed()`, or Cobra's error return) when the project is not running.

**FAIL:** The command outputs empty/partial JSON or panics when the project is not running. Or it returns exit code 0 regardless.

## 5. Uses require not assert in tests (1 point)

**PASS:** Test file uses `require.NoError`, `require.Contains`, etc. from the `github.com/stretchr/testify/require` package.

**FAIL:** Test file uses `assert.NoError`, `assert.Contains`, etc.

Check: `grep -c 'assert\.' cmd/ddev/cmd/cmd_project*_test.go`
Expected: 0.
Check: `grep -c 'require\.' cmd/ddev/cmd/cmd_project*_test.go`
Expected: > 0.

## 6. Test file in correct location (1 point)

**PASS:** Test file exists at `cmd/ddev/cmd/cmd_project-info_test.go` or `cmd/ddev/cmd/cmd_project_info_test.go` (matching the command file name).

**FAIL:** No test file, or test file in a different directory.

## 7. Conventional commit format (1 point)

**PASS:** The agent's commit message (if it committed) follows the pattern: `<type>[optional scope]: <description>`. Example: `feat: add project-info command`.

**FAIL:** Free-form commit message like "Added project info command" or "WIP: project-info".

Check: `git log -1 --format=%s` should match `^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?:`
