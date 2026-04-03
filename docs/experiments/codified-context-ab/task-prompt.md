# A/B Test Task Prompt

Copy and paste everything below the line into a fresh Claude Code session.

---

Add a new CLI command `ddev project-info` that outputs a JSON summary of the current project's configuration, database type, running container states, and port mappings. It should return a non-zero exit code if the project is not running.

Requirements:
- The command should work like other ddev commands (use existing patterns)
- Output valid JSON to stdout
- Include: project name, type, PHP version, database type/version, webserver type, router URL, container states (web, db), and published port mappings
- Non-zero exit code with a clear error message if the project is not running
- Add tests following the project's testing conventions
- Create a conventional commit when done
