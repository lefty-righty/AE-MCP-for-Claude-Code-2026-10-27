---
name: after-effects-project-organize
description: Apply Kerry's Assets, Comps, and Solids folder standard inside the After Effects Project panel when creating, building, editing, importing into, or organizing AE projects. Companion to project-organize for on-disk folders; does not relocate disk media or automatically restructure unrelated existing projects.
---

# After Effects Project Organize

Use Kerry's approved Project-panel structure for new AE jobs and newly created/imported items. Explicit task-specific instructions take precedence. For an existing project, inspect first; a focused creative edit does not itself authorize a wholesale reorganization. Apply a full migration when the user asks for or approves it.

## Standard inside AE

```text
Assets
|-- AEPs
|   `-- Imported Project.aep
|       `-- (preserved imported project hierarchy)
|-- Audios
|   |-- VO
|   `-- Music
|-- Images
`-- Footages
Comps
Solids
```

- Keep these names and capitalization exact. Do not substitute numbered MASTER, SCENES, or MEDIA top-level folders.
- Create the base hierarchy above for a new project or an approved full migration. Empty base folders are intentional; don't manufacture assets to populate them.
- Working-project master compositions and precompositions belong under Comps. Keep small jobs flat; use descriptive subfolders within Comps only when useful for scale or multiple deliverables. Imported AEP packages are the exception described below.
- Imported still images and vector artwork belong under Assets/Images. Add categories such as AI, Logos, Cars, Characters or Locations only when relevant. AI means AI-generated assets, not automatically every .ai Illustrator file.
- Videos and imported image sequences that play as footage belong under Assets/Footages. Add AI, Cars, Characters or other relevant subfolders only as needed.
- Audio-only sources belong under Assets/Audios; use VO or Music when the role is known. Add SFX when needed. Don't duplicate a video into Audios merely because it includes sound.
- Generated SolidSource project items belong under Solids. Text, shape, camera and light layers remain inside their compositions, not in a project folder. Classify actual source types rather than treating every FootageItem as a video or every solid layer as an image.
- Preserve compound PSD/AI imports: their compositions go under Comps and their linked image sources under Images, retaining useful source subfolders. Don't flatten or duplicate layers to organize them.
- Reuse exact-name folders under the correct parent; names alone are not unique IDs. On ambiguous duplicates or case conflicts, inspect and resolve with the user rather than deleting or renaming unrelated content.

## Imported AEPs and project packages

- Keep each imported AEP in its own Project-panel folder under Assets/AEPs, named for the source project (for example, Assets/AEPs/MFD4115769AH_BH.aep). Move its existing import wrapper as a unit; create a wrapper only when needed and the imported items' membership is known.
- Preserve that package's internal hierarchy, including its Comps, Assets, Solids, and any nested imported AEP folders. Do not extract its compositions into the working project's Comps or redistribute its media and solids into the top-level asset categories. This rule takes precedence over the general type-based sorting rules above.
- Keep imported template packages such as Motion Bro Folder together under Assets/AEPs as well, preserving their internal names and hierarchy.
- Use Assets/AEPs when imported projects or template packages are present. The example Imported Project.aep is illustrative, not a folder to create literally.
- For previously reorganized projects, do not guess which items belong to an imported AEP. Use the original hierarchy or a recorded item-ID inventory to restore membership during an authorized organization pass; ask if provenance is ambiguous. Do not duplicate shared sources to reconstruct a package.
- This is Project-panel organization, not a request to save separate AEP files or move source files on disk.

## Execution

1. Confirm the active AE project and its intended save destination. Inspect saved/dirty state, existing hierarchy, item IDs, source paths and missing media. If its file has moved on disk or the save destination is ambiguous, resolve that before saving; don't recreate a stale folder silently.
2. Use the available AE connector, not disk-directory commands, for Project-panel folders. With the `after-effects-local` MCP, discover exact operations through `ae_catalog` (for example `folder.create`, `item.move_to_folder`, `item.list`), follow its `WORKFLOW.md`, and honor its execution constraints. Do not edit the installed MCP to impose this convention. If AE access is unavailable, report that and provide the plan; do not claim the AEP was changed.
3. Before an approved broad migration, preserve a recoverable saved copy or backup. Record existing comp/layer/source counts and IDs, paths, and render-relevant state. Do not close or reset an unsaved project to simplify the task.
4. Identify imported AEP and template-package boundaries first. Create/reuse the standard folders, move those packages intact under Assets/AEPs, then sort working-project items by verified IDs. Use the smallest folder-only edits. Preserve composition, layer and source names, IDs, timing, expressions, effects, keys, settings, source paths and render queue. Folder renames are allowed in an approved migration, but check for expressions or scripts that depend on folder names.
5. Only remove obsolete folders after verifying they are empty and their removal is within the approved migration. Never recursively delete a folder containing items. Do not use reduce-project, remove-unused-footage, consolidation, or auto-fix-expressions as organization shortcuts.
6. Inspect results, including partial batch results before retries. A second pass over a compliant project should create no duplicates and require no moves.
7. Verify working-project comps are below Comps and their assets are correctly routed; verify imported AEP/template packages remain intact below Assets/AEPs. Comps, assets, and solids inside those packages are valid exceptions to top-level routing. Compare before/after source paths, comp/layer counts and render-relevant data; check missing footage and expression state. Render and inspect a representative frame for a migration, expanding visual checks if anything beyond folder metadata changed. Do not change content merely to test a folder-only operation.
8. Save to the confirmed destination and report the actual hierarchy, backup and any unresolved issues. Preserve creative approval status; folder cleanup is not keeper approval.

## Separate from disk organization

The companion project-organize skill owns the disk scaffold: README.md, Assets/Audios, Assets/Footages, Assets/Images, Exports and Projects. Its script does not create AE Project-panel folders. This skill does not add Comps or Solids directories on disk, relocate media, collect files, relink sources or overwrite README files automatically. Obtain task-specific authority for those actions when needed; reference approved handoff documentation rather than silently moving existing files.
