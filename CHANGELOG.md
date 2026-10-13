# Changelog

## Unreleased

- Fix: register the agent and the `/fix-build-loop` prompt with `path` entries in `package.json`. Version 1.0.0 did not load them from an installed `.vsix`.
- Fix: the attempt-limit hook never ran in 1.0.0. The hook is now in the agent's `hooks` frontmatter and runs only for `al-build-loop`. Copy the two scripts into `.github/hooks` of your AL project one time (see README).
- Fix: `/fix-build-loop` now runs the `al-build-loop` agent (`agent:` frontmatter).
- Fix: the hook scripts no longer auto-approve other tool calls, and `loop-limit.sh` no longer needs `jq`.
- Agent tools use the qualified AL tool names and include `read/readFile`.
- Requires VS Code 1.111 or later and the **Local** session target.

## 1.0.0 — 2026-09-02

- MB AL Loop Demo extension for Business Central AL
- Custom agent that fixes AL compile errors using a self-checking loop
- `/fix-build-loop` slash command for invoking the build fix agent
- Hard attempt limit of 3 enforced by workspace hooks to prevent infinite loops
- Cross-platform support: macOS, Linux (bash), and Windows (PowerShell)
