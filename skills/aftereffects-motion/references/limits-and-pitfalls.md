# Limits and Pitfalls

What the `after-effects-local` MCP can and cannot do. Read before scoping any build.

---

## Limits of the MCP

**Only declared operations.** Everything goes through `ae_do` operations listed in `ae_catalog`. Arbitrary script evaluation is disabled. If no operation covers a step, that step needs a JSX fallback (Mode B) or a manual action. Check the catalog before deciding something is impossible: shape contents, Trim Paths, Repeaters, text animators, keyframe easing, expressions, masks, and render-queue settings all have operations.

**Read-only mode.** When the server runs read-only, reads and `ae_render_frame` still work, but edits and `ae_save_project` are refused until the user unlocks them. `ae_catalog` reports the active policy.

**Rendering is the user's call.** `render.start` exists but processes the whole queue. Render or export only when asked, and isolate the intended queue item first.

**Vision is per-frame.** `ae_render_frame` shows one frame at a time; it is not playback. Judge motion by rendering several frames across a move and reading keyframe values and easing. Ask the user to RAM-preview for the feel of the whole thing.

**Timeouts are unknown outcomes.** A timed-out operation may have finished inside AE. Inspect before retrying.

---

## ExtendScript quirks (ES3, not modern JS)

AE's scripting engine runs ExtendScript, which is roughly ES3. It does not understand modern syntax.

**No `const` or `let`.** Use `var` only.

```js
// breaks
const x = 5;
let y = 10;

// correct
var x = 5;
var y = 10;
```

**No arrow functions.**

```js
// breaks
var result = items.map(i => i.name);

// correct
var result = [];
for (var i = 0; i < items.length; i++) {
    result.push(items[i].name);
}
```

**No template literals.**

```js
// breaks
var msg = `Layer: ${name}`;

// correct
var msg = "Layer: " + name;
```

**`Array.indexOf` not always available.** Check before using, or write a manual loop.

```js
// safe fallback
function indexOf(arr, val) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] === val) return i;
    }
    return -1;
}
```

**No `try/catch` on property access (no optional chaining either).** Always check for null before accessing nested properties.

---

## Connection requirements

The MCP only works when After Effects is open, not blocked by a modal dialog, and **Allow Scripts to Write Files and Access Network** is on (Edit > Preferences > Scripting & Expressions). If calls start failing mid-session, stop and ask the user to check AE for a dialog. Don't keep retrying.

---

## Undo: one step per MCP call, unreliable after JSX

Each `ae_do` call runs in one automatic undo group, so Ctrl+Z or `project.undo` reverts the whole call (a `batch.run` included). Never open your own undo group inside an MCP call, and call `project.undo` alone, not inside a batch.

User-run JSX is different: AE's Undo (Ctrl+Z) cannot reliably reverse script operations, and may not recover trashed work. Either way, confirm the project is saved before editing and save results as a new versioned AEP. The most recent save is the real undo.

---

## State staleness

If the user has moved keyframes, adjusted values, or added layers manually since your last change, your model of the comp is stale. Do not patch based on stale assumptions. Re-read with `ae_comp_info` / `ae_layer_info`, then patch.

---

## Performance: batch, don't fall back

Each MCP call has round-trip overhead. Group related steps with `batch.run` and audit whole comps with `ae_layer_info` `"all"`, rather than one call per property. Drop to JSX only for steps the catalog can't do, not for speed.

---

## What the MCP can do (for reference)

Call `ae_catalog` for the live list and schemas. Main categories: `comp`, `layer`, `shape`, `text`, `keyframe`, `property`, `expression`, `effect`, `mask`, `marker`, `render`, `footage`, `item`, `font`, `project`, `batch`. Read tools: `ae_project_info`, `ae_comp_info`, `ae_layer_info`, `ae_version_info`. Vision: `ae_render_frame`. Save: `ae_save_project` (pass a new path for a versioned copy).
