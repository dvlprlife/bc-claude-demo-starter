---
name: reset-demo
description: Reset the demo — remove the published extension (and test app) from the Business Central environment in app/.vscode/launch.json, and remove the generated documents, wireframes, AL source, test app, and packages from this folder, so that the demo can run again from a fresh instance. Use when the user asks to reset the project, reset the demo, clean up, or start over.
---

# Reset the demo

The user's request to reset is the approval for all the steps below. Do not ask for a second confirmation. This applies to this folder and to the environment in `app/.vscode/launch.json` only.

## 1. Collect the details before you remove anything

Read these values first. Step 3 restores `app/app.json`, and after that the extension details are gone.

- From `app/app.json`: `id`, `name`, `publisher`, `version`.
- From `test/app.json` (if it exists): `id`, `name`, `publisher`, `version`.
- From `app/.vscode/launch.json` (the first configuration): `environmentName`, `environmentType`, `tenant`.

## 2. Remove the extension from the environment

Remove the test app first, then the main app. The test app depends on the main app.

1. Look for an AL MCP tool that uninstalls or unpublishes an extension. Search with ToolSearch for `+al unpublish` and `+al uninstall`.
2. If there is such a tool, call it for each app with the environment values from `launch.json`. Delete the extension data, so that the next demo starts with empty tables.
3. If there is no such tool, the AL tools (18.0.43) cannot remove an extension. Give the user these steps, with the real values:
   1. Open `https://businesscentral.dynamics.com/<tenant>/<environmentName>/?page=2500` (Extension Management).
   2. Select the test app "<test app name>" (if there is one). Select **Uninstall**, select **Delete Extension Data**, and confirm. Then select **Unpublish**.
   3. Do the same for "<app name>" by <publisher>.
4. If the extension was not published in this run (there is no `.output` folder and the `app/app.json` version is the baseline version), skip this step.

## 3. Reset the folder

Run in PowerShell from the repo root:

```powershell
./scripts/Reset-Demo.ps1
```

The script removes:

- `docs/request.md`, the FRD and PRD files (all versions), and the files in `docs/wireframes/`
- the user guide and its images in `docs/user-guide/`
- the AL source in `app/src/`, the translation files in `app/Translations/`, the test app in `test/`, and the packages in `.output/`
- the dashboard anchor in `.dashboard/`

It restores `app/app.json` from `supporting-files/app.baseline.json`.

It keeps the workflow: `docs/templates/`, `docs/README.md`, `reference/`, `scripts/`, `supporting-files/`, `.claude/`, `app/.vscode/`, `.mcp.json`, `CLAUDE.md`, and the symbols in `app/.alpackages/`.

## 4. Report

Tell the user in a few lines:

- The files and folders that the script removed
- The environment result: the apps removed by the tool, or the manual steps from Step 2.3
- That the folder is ready for a new request. Recommend a new Claude Code session for the next demo, so that the session starts with no memory of the last run.

## Baseline

`supporting-files/app.baseline.json` is the `app/app.json` of a fresh demo. The bootstrap writes it. If the user changes the starting `app/app.json` (for example a new ID range or BC version), copy the new `app/app.json` to the baseline when no demo run is in the folder.
