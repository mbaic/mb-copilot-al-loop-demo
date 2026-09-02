# MB AL Loop Demo

This extension is a small, working example of **loop engineering** for Business Central AL development.

Loop engineering means this: an AI agent tries a step, checks the result, and tries again until it succeeds or reaches a limit. This extension shows the pattern on one task: a compile error in an AL project.

Read the background post first: [Loop Engineering: Give Your AL Copilot a Repeat Button](https://mbaic.github.io/2026/07/03/loop-engineering-business-central-al/).

## What this extension adds to VS Code

This extension adds three things to Copilot Chat:

1. **A custom agent** named `al-build-loop`. This agent builds your AL project, reads the errors, and fixes them.
2. **A slash command**, `/fix-build-loop`. Type this command to start the agent on a task.
3. **A hard attempt limit.** The agent tries **3 times**. On the 4th try, a script blocks the build tool and stops the agent. The limit is code, not a request to the model. The model cannot skip it.

This extension does not add a new AI model. It does not add a new compiler. It uses the tools that the AL Language extension already gives to Copilot: `al_build` and `al_getdiagnostics`. This extension only adds the loop around them.

## Before you start

You need:

- Visual Studio Code, a recent version. Agent hooks are a **Preview** feature. Update VS Code if you do not see the behavior described below.
- The **AL Language** extension, version 17.0 or later.
- **GitHub Copilot Chat**, installed and signed in.
- An AL project open in VS Code, with `app.json` at its root.
- Copilot Chat set to **Agent** mode.

You do not need Node.js, npm, or any build tool to use this extension. You only need these tools if you want to change the extension and repackage it.

## Install

1. Go to the [Releases](../../releases) page of this repository.
2. Download the file `mb-al-loop-demo-<version>.vsix`.
3. Open VS Code.
4. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS) to open the Command Palette.
5. Type **Extensions: Install from VSIX** and press Enter.
6. Select the downloaded `.vsix` file.
7. Reload VS Code if it asks you to.

## Try it

1. Open an AL project. Pick a codeunit, page, or table with a known compile error. If you do not have one, break something on purpose. For example, reference a field name that does not exist.
2. Open Copilot Chat.
3. Type this command and press Enter:

   ```
   /fix-build-loop the project does not compile, please fix it
   ```

4. Copilot may ask you to approve a tool call, such as running the build or editing a file. Review each request and select **Allow**.
5. Watch the chat window. The agent reports each attempt: what error it found, what fix it tried, and the build result.
6. The agent stops on its own. It stops when the build is clean, or when it reaches 3 attempts.
7. **Review the changes yourself.** Open the diff in Source Control. Read every line. Commit only after you agree with the fix.

This extension never commits code for you. It only edits files in your working folder, the same way you would edit them yourself.

## What is inside this repository

| File | Purpose |
|------|---------|
| `.github/agents/al-build-loop.agent.md` | The custom agent. Defines its allowed tools and its loop instructions. |
| `.github/prompts/fix-build-loop.prompt.md` | The `/fix-build-loop` slash command. |
| `hooks/hooks.json` | Registers the attempt-limit script to run before every tool call. |
| `hooks/loop-limit.sh` | The attempt-limit script, for macOS and Linux. |
| `hooks/loop-limit.ps1` | The attempt-limit script, for Windows. |
| `package.json` | The extension manifest. Lists the files above as contributions. No compiled code. |

## How the attempt limit works

Before the agent runs the AL build tool, VS Code runs the script in `hooks/loop-limit.sh` (or `.ps1` on Windows). The script does three things:

1. It checks whether the current tool call is a build.
2. If it is, the script adds 1 to a counter for this chat session.
3. If the counter is 3 or lower, the script allows the build. If the counter is higher than 3, the script blocks the build and tells the agent why.

This means the limit works even if the model ignores its own instructions. The block happens in the script, not in the model's judgment.

## What this demo does not do

This demo is intentionally simple. It does not cover every case:

- It handles one compile error at a time. It does not fix a project with many unrelated errors in one pass.
- It checks the compiler only. It does not run test codeunits.
- It does not connect to a CI pipeline, such as AL-Go for GitHub.
- The attempt limit is fixed at 3. To change it, edit the number in `hooks/loop-limit.sh` and `hooks/loop-limit.ps1`.
- It never commits, publishes, or pushes code. You stay in control of every change.

## Troubleshooting

**The agent does not stop after 3 attempts.**
Check that VS Code loaded the hook. Run the command **Developer: Show Agent Debug Logs** and look for `loop-limit`. Some organizations turn off agent hooks by policy. Ask your VS Code administrator if this applies to you.

**The `/fix-build-loop` command does not appear.**
Confirm the extension is installed and enabled. Open the Command Palette and run **Chat: Open Customizations** to see all loaded agents, prompts, and hooks.

**Copilot cannot find `al_build` or `al_getdiagnostics`.**
Update the AL Language extension to version 17.0 or later. These tools ship with the AL extension, not with this demo.

## Background reading

- [Loop Engineering: Give Your AL Copilot a Repeat Button](https://mbaic.github.io/2026/07/03/loop-engineering-business-central-al/) — the concept this extension demonstrates.
- [The AL Coding Harness: Your Custom Dashboard](https://mbaic.github.io/2026/06/29/small-agent-harness-business-central-al/) — background on custom agents and instructions for AL.

## License

MIT. See [LICENSE](LICENSE).
