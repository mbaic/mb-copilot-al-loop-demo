# MB AL Loop Demo

This extension is a small, working example of **loop engineering** for Business Central AL development.

Loop engineering means this: an AI agent tries a step, checks the result, and tries again until it succeeds or reaches a limit. This extension shows the pattern on one task: a compile error in an AL project.

Read the background post first: [Loop Engineering: Give Your AL Copilot a Repeat Button](https://mbaic.github.io/2026/07/03/loop-engineering-business-central-al/).

## What this extension adds to VS Code

This extension adds three things to Copilot Chat:

1. **A custom agent** named `al-build-loop`. This agent builds your AL project, reads the errors, and fixes them.
2. **A slash command**, `/fix-build-loop`. Type this command to start the agent on a task.
3. **A hard attempt limit.** The agent tries **3 times**. On the 4th try, a script blocks the build tool and stops the agent. The limit is code, not a request to the model. The model cannot skip it. You must copy the script into your AL project one time. Refer to [Set up the attempt limit](#set-up-the-attempt-limit).

This extension does not add a new AI model. It does not add a new compiler. It uses the tools that the AL Language extension already gives to Copilot: `al_build` and `al_getdiagnostics`. This extension only adds the loop around them.

## Before you start

You need:

- Visual Studio Code, version 1.111 or later. Agent hooks are a **Preview** feature.
- The **AL Language** extension, version 17.0 or later.
- **GitHub Copilot Chat**, installed and signed in.
- An AL project open in VS Code, with `app.json` at its root. If your workspace has more than one folder, the AL project must be the first folder.
- A trusted workspace. VS Code does not run hooks in Restricted Mode.
- The setting `chat.useHooks` set to on. This is the default value.
- The **Session Target** in Copilot Chat set to **Local**. The slash command and the attempt limit work only in Local sessions.
- On macOS and Linux: `bash`. On Windows: Windows PowerShell.

You do not need Node.js, npm, or any build tool to use this extension. You only need these tools if you want to change the extension and repackage it.

## Install

1. Go to the [Releases](../../releases) page of this repository.
2. Download the file `mb-al-loop-demo-<version>.vsix`.
3. Open VS Code.
4. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on macOS) to open the Command Palette.
5. Type **Extensions: Install from VSIX** and press Enter.
6. Select the downloaded `.vsix` file.
7. Reload VS Code if it asks you to.

## Set up the attempt limit

Do this procedure one time for each AL project.

The agent starts the attempt-limit script from the root folder of your AL project. A hook command has no variable for the install folder of an extension. Thus, the script must be in your project.

1. Open a terminal in the root folder of your AL project.
2. Copy the two script files from the extension folder to the folder `.github/hooks` in your project.

   On macOS or Linux:

   ```bash
   mkdir -p .github/hooks
   cp ~/.vscode/extensions/mbaic.mb-al-loop-demo-*/hooks/loop-limit.* .github/hooks/
   ```

   On Windows (PowerShell):

   ```powershell
   New-Item -ItemType Directory -Force -Path .github\hooks | Out-Null
   Copy-Item "$env:USERPROFILE\.vscode\extensions\mbaic.mb-al-loop-demo-*\hooks\loop-limit.*" .github\hooks\
   ```

3. Make sure that the folder `.github/hooks` contains `loop-limit.sh` and `loop-limit.ps1`.
4. Commit the two files. Your team then gets the same limit.

If you use VS Code Insiders, replace `.vscode` with `.vscode-insiders` in the commands. If the extensions folder has more than one version of this extension, use the files from the highest version. You can also download the two files from the [`hooks`](hooks) folder of this repository.

Do not add a `hooks.json` file for these scripts. The agent starts the scripts itself. A `hooks.json` file in `.github/hooks` runs the scripts for all agents.

## Try it

1. Open an AL project. Pick a codeunit, page, or table with a known compile error. If you do not have one, break something on purpose. For example, reference a field name that does not exist.
2. Open Copilot Chat. Set the **Session Target** to **Local**.
3. Start a new chat. The attempt counter counts all builds in one chat session.
4. Type this command and press Enter:

   ```
   /fix-build-loop the project does not compile, please fix it
   ```

5. Copilot can ask you to approve a tool call, such as a build or a file edit. Review each request and select **Allow**.
6. Watch the chat window. The agent reports each attempt: the error it found, the fix it tried, and the build result.
7. The agent stops on its own. It stops when the build is clean, or when it reaches 3 attempts.
8. **Review the changes yourself.** Open the diff in Source Control. Read every line. Commit only after you agree with the fix.

This extension never commits code for you. It only edits files in your working folder, the same way you would edit them yourself.

## What is inside this repository

| File | Purpose |
|------|---------|
| `agents/al-build-loop.agent.md` | The custom agent. Defines its allowed tools, its loop instructions, and the hook that starts the attempt-limit script. |
| `prompts/fix-build-loop.prompt.md` | The `/fix-build-loop` slash command. Starts the `al-build-loop` agent. |
| `hooks/loop-limit.sh` | The attempt-limit script, for macOS and Linux. You copy it into your AL project. |
| `hooks/loop-limit.ps1` | The attempt-limit script, for Windows. You copy it into your AL project. |
| `package.json` | The extension manifest. Registers the agent and the slash command. No compiled code. |

## How the attempt limit works

The agent file has a `hooks` section. When the `al-build-loop` agent is active, VS Code runs `.github/hooks/loop-limit.sh` (or `.ps1` on Windows) before each tool call. The script does these steps:

1. It checks if the tool call is a build (`al_build`). If it is not a build, the script gives no decision. VS Code then asks for your approval as usual.
2. If it is a build, the script adds 1 to a counter for this chat session.
3. If the counter is 3 or lower, the script lets the build continue. If the counter is higher than 3, the script blocks the build and tells the agent why.

Thus, the limit works also when the model ignores its instructions. The script blocks the build, not the model.

The hook runs only for the `al-build-loop` agent. Other agents can use `al_build` without a limit.

## What this demo does not do

This demo is intentionally simple. It does not cover every case:

- It handles one compile error at a time. It does not fix a project with many unrelated errors in one pass.
- It checks the compiler only. It does not run test codeunits.
- It does not connect to a CI pipeline, such as AL-Go for GitHub.
- The attempt limit is fixed at 3. To change it, edit `LIMIT=3` in `.github/hooks/loop-limit.sh` and `$Limit = 3` in `.github/hooks/loop-limit.ps1` in your AL project.
- The attempt limit works only in **Local** sessions. Copilot sessions on the Agent Host do not load prompt files or agent hooks.
- It never commits, publishes, or pushes code. You stay in control of every change.

## Troubleshooting

**The agent does not stop after 3 attempts.**
Do these checks:

1. Make sure that `.github/hooks/loop-limit.sh` and `.github/hooks/loop-limit.ps1` are in your AL project. Refer to [Set up the attempt limit](#set-up-the-attempt-limit).
2. Make sure that the **Session Target** is **Local** and that the `al-build-loop` agent is selected.
3. Make sure that the workspace is trusted and that the setting `chat.useHooks` is on.
4. Open the Command Palette and run **Developer: Open Agent Debug Logs**. Find the `PreToolUse` hook events for the build tool.
5. Open the **Output** panel and select the channel **GitHub Copilot Chat Hooks**. Read the script output and the errors.

Some organizations turn off agent hooks by policy. Ask your VS Code administrator if this applies to you.

**VS Code shows a hook warning each time the agent uses a tool.**
VS Code cannot find or start the script. Do the procedure in [Set up the attempt limit](#set-up-the-attempt-limit). The build is not blocked until the script runs correctly.

**The `/fix-build-loop` command or the agent does not appear.**
Make sure that the extension is installed and enabled, and that VS Code is version 1.111 or later. Make sure that the **Session Target** is **Local**. Open the Command Palette and run **Chat: Open Customizations** to see all loaded agents and prompts.

**Copilot cannot find `al_build` or `al_getdiagnostics`.**
Update the AL Language extension to version 17.0 or later. These tools ship with the AL extension, not with this demo.

## Background reading

- [Loop Engineering: Give Your AL Copilot a Repeat Button](https://mbaic.github.io/2026/07/03/loop-engineering-business-central-al/) — the concept this extension demonstrates.
- [The AL Coding Harness: Your Custom Dashboard](https://mbaic.github.io/2026/06/29/small-agent-harness-business-central-al/) — background on custom agents and instructions for AL.

## License

MIT. See [LICENSE](LICENSE).
