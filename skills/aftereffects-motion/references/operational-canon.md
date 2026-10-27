# Operational Canon

How a session actually runs. Load at session start.

## Connection check (start of every session)

The `after-effects-local` MCP talks to the running After Effects. It needs:

1. After Effects open, with the project loaded and no modal dialog showing.
2. **Edit > Preferences > Scripting & Expressions > Allow Scripts to Write Files and Access Network** turned on.

Then:

- `ae_version_info` confirms the connection and AE version.
- `ae_project_info` gives the project path, the `dirty` (unsaved changes) flag, and every item with its ID.

If a call times out, stop. Ask the user to bring AE to the front and dismiss any dialog. Do not retry in a loop. Also check for a second After Effects process with no window; a stray instance can swallow the requests. If edits are refused, the server is in read-only mode; ask the user whether to unlock them.

## Choose Mode A or Mode B before acting

Mode A. MCP operations. Good for:

- Inspecting comps, layers, keyframes, expressions, shape contents, text
- Building animations: layers, shape groups, Trim Paths, Repeaters, text animators, keyframes with custom easing, expressions, effects, masks, markers
- Render-queue setup and auditing
- Iterating while the user watches

Use `ae_catalog` to find the exact operation and its parameters. Group related steps with `batch.run` so a build is a handful of calls, not dozens. Remember a batch is not a transaction.

Mode B. JSX scripts, run by the user via `File > Scripts > Run Script File...`. Use only when:

- `ae_catalog` has no operation for a required step, or
- The user explicitly wants a reusable script they can run themselves.

When you fall back, name the step that forced it.

## The iteration loop in detail

1. **User describes the goal.** Plain language is fine. They will sometimes drop a reference image. Treat reference images as design direction, not pixel-exact targets, unless they say otherwise.

2. **Ask one blocking question, if any.** Examples of blocking: target duration unclear, target framerate/comp size unknown, source asset path missing. Don't ask design-taste questions ("should the easing be soft or sharp?"); make a call and let them push back.

3. **Inspect.** `ae_project_info`, then `ae_comp_info` for the target comp, then `ae_layer_info` with `"all"` if you'll touch existing layers. Confirm the project is saved before editing.

4. **Build.** Mode A by default. If Mode B, save the JSX in the project's working folder (ask once and remember it) as `<purpose>_<vN>.jsx`, for example `lockup_reveal_v3.jsx`, and tell the user: "Save your project (Ctrl+S), then run `File > Scripts > Run Script File... > lockup_reveal_v3.jsx`."

5. **Verify it yourself.** Read back the properties you changed. Render frames with `ae_render_frame` at the moments that matter: the start of each move, the peak, the settle. Fix anything visibly wrong before you show the user.

6. **Show the user.** The frames, plus the timing in numbers (durations, easing values, stagger offsets). They preview in AE (numpad `0` for RAM preview) and react.

7. **Patch.** If the user changed the comp by hand, re-inspect before patching.

## Seeing the comp

`ae_render_frame` renders a single frame to PNG. Use it at specific times instead of asking for screenshots:

- Timing questions: render the start and end of the problem range.
- Layering questions: pair a frame with `ae_comp_info` layer order.
- Ask the user for a screenshot only for things a frame can't show (timeline panel, graph editor, UI state).

## Inspecting state

If the user has adjusted properties or added layers since your last change, your model of the comp is stale. Don't push changes blind. Re-read with `ae_comp_info` and `ae_layer_info` (they return transforms, effects, masks, text, shape contents, and keyframes). The JSX state-dump script in `scripting-patterns.md` is only for sessions without the MCP.

## File organisation

Work inside the project's own folder structure (Assets, Exports, Projects). Keep scripts next to the project file they belong to, and name them for what they do, not when they were made.

## Save discipline

Before editing, check `dirty` in `ae_project_info`. If there are unsaved changes, ask the user to save (Ctrl+S) first. Save your result as a new versioned AEP with `ae_save_project` and a new path; never overwrite the original. AE's Undo (Ctrl+Z) is unreliable on script-driven changes; the most recent save is the real undo.

## Common things the user might say

| User says... | They mean... |
|---|---|
| "rerun it" | Re-apply the same operations or script, no changes |
| "check it" / "what does it look like" | Render frames at the key moments and report |
| "patch the timing" | Change keyframe times or easing, not the structure |
| "restart this section" | Throw away the current approach, propose a new one |
| "0 on numpad" | RAM preview (just FYI, no action needed) |
