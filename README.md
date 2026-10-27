# After Effects MCP for Claude Code

This package lets Claude Code inspect and build in Adobe After Effects on your own computer. It also adds motion design skills, so Claude makes deliberate timing and easing choices instead of software defaults.

Everything runs locally. There is no account, cloud service, or credit cost in this package.

## Requirements

- Windows 10 or 11, 64-bit
- Adobe After Effects 2026, installed and licensed (other versions need their own live check)
- Claude Code: the Claude desktop app's Code tab, or the `claude` command line

Node.js is included. You don't need to install anything else.

## Install

1. Extract this whole zip to a local folder. Don't run it from inside the zip or from a network drive.
2. Double-click `Install-For-Claude.cmd`.
3. Wait for "Done." Extraction can take a few minutes while antivirus scans the files.

The installer:

- verifies the release checksum and every file inside it
- installs the MCP to `%LOCALAPPDATA%\AfterEffectsMCP`
- puts its After Effects dispatcher script in `Documents\CodexIntegrations\StandaloneAE`
- backs up your Claude config, then registers the MCP as `after-effects-local`
- copies four skills into `%USERPROFILE%\.claude\skills`, skipping any you already have
- runs an offline self-test that does not launch After Effects

It installs in read-only mode. Claude can read projects and render preview frames, but can't change anything. To allow editing, run this from the extracted folder:

```
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-For-Claude.ps1 -AllowEdits
```

If After Effects is installed somewhere unusual, add `-AfterEffectsExe "D:\path\to\Support Files\AfterFX.exe"`.

## After installing

1. Fully quit and reopen Claude. On Windows, quit it from the system tray. Or start a new Claude Code session.
2. Open After Effects with a project. Turn on **Edit > Preferences > Scripting & Expressions > Allow Scripts to Write Files and Access Network**.
3. Run the live check. It's read-only and changes nothing:
   ```
   powershell -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\AfterEffectsMCP\Test-Connection.ps1" -Live
   ```
4. In Claude, ask: "Call ae_version_info and ae_project_info on after-effects-local and tell me what you see." It should report your After Effects version and open project.

## What's included

| Item | What it does |
|---|---|
| After Effects MCP | Eight tools: read project, comp, and layer info, render frames, save, and run 197 declared operations such as layers, shapes, Trim Paths, text animators, keyframes, easing, expressions, effects, masks, and render queue. Arbitrary script execution is disabled. |
| `motion-design` skill | Timing, spacing, easing, the 12 principles, composition for motion, defaults to avoid |
| `aftereffects-motion` skill | How to build in After Effects with this MCP, plus expressions, shape layers, text animators, effects, and render references |
| `motion-design-critique` skill | Diagnoses motion that looks off, script errors, and render problems |
| `after-effects-project-organize` skill | The Assets / Comps / Solids Project-panel folder standard |

Skills load automatically when your request matches them. Name the tool when you hand off to building, like "build this in AE." You can also call one directly, for example `/aftereffects-motion`.

## Working safely

- Save your project before letting Claude edit. Claude saves its results as a new versioned AEP and keeps your original.
- Each MCP operation is a single undo step in After Effects.
- Claude renders or exports only when you ask.
- Only one agent should drive After Effects at a time.

## If something goes wrong

- **Calls time out.** Bring After Effects to the front and dismiss any dialog. Check the scripting preference above. Look in Task Manager for a second After Effects process with no window.
- **Claude doesn't see the MCP.** Fully quit and reopen Claude.
- More detail is in `%LOCALAPPDATA%\AfterEffectsMCP\TROUBLESHOOTING.md` and `WORKFLOW.md`.

## To uninstall

1. Remove the `after-effects-local` entry from `mcpServers` in `%USERPROFILE%\.claude.json`. The installer left a dated backup beside it.
2. Delete `%LOCALAPPDATA%\AfterEffectsMCP` and `Documents\CodexIntegrations\StandaloneAE`.
3. Delete the four skill folders from `%USERPROFILE%\.claude\skills`.

## Credits and licenses

The MCP server is a modified copy of `kumoproductions/mcp-aftereffects` (MIT). The motion design skills are adapted from `LobzyJay/motion-design-with-claude-and-codex` (MIT), edited for this MCP. License files are included in the release and in each skill folder.
