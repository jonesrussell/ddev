package testsetup

import (
	"fmt"
	"log"
	"os"
	osexec "os/exec"
	"path/filepath"
	"runtime"

	"github.com/ddev/ddev/pkg/fileutil"
)

// ResolveDdevBinary returns the DDEV binary that tests should execute.
// It refuses to fall back to an arbitrary ddev on PATH to avoid accidentally
// running tests against an installed release instead of the current tree.
func ResolveDdevBinary() (string, error) {
	if bin := os.Getenv("DDEV_BINARY_FULLPATH"); bin != "" {
		if !fileutil.FileExists(bin) {
			return "", fmt.Errorf("DDEV_BINARY_FULLPATH is set to %s but that file does not exist", bin)
		}
		return bin, nil
	}

	repoRoot, err := findRepoRoot()
	if err != nil {
		return "", fmt.Errorf("failed to locate repository root: %w", err)
	}

	binaryName := "ddev"
	if runtime.GOOS == "windows" {
		binaryName += ".exe"
	}

	candidate := filepath.Join(repoRoot, ".gotmp", "bin", runtime.GOOS+"_"+runtime.GOARCH, binaryName)
	if fileutil.FileExists(candidate) {
		return candidate, nil
	}

	pathBin, lookPathErr := osexec.LookPath("ddev")
	if lookPathErr == nil {
		return "", fmt.Errorf("DDEV_BINARY_FULLPATH is not set and repo-local test binary %s was not found; refusing to use PATH-resolved ddev at %s. Run `make`, use `make testcmd`/`make testpkg`, or set DDEV_BINARY_FULLPATH explicitly", candidate, pathBin)
	}

	return "", fmt.Errorf("DDEV_BINARY_FULLPATH is not set and repo-local test binary %s was not found. Run `make`, use `make testcmd`/`make testpkg`, or set DDEV_BINARY_FULLPATH explicitly", candidate)
}

// MustResolveDdevBinary returns the test DDEV binary or aborts the current test process.
func MustResolveDdevBinary() string {
	bin, err := ResolveDdevBinary()
	if err != nil {
		log.Fatalf("MustResolveDdevBinary: %v", err)
	}
	return bin
}

func findRepoRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}

	for {
		if fileutil.FileExists(filepath.Join(dir, "go.mod")) && fileutil.FileExists(filepath.Join(dir, "Makefile")) {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", fmt.Errorf("repository root not found from %s", dir)
		}
		dir = parent
	}
}
