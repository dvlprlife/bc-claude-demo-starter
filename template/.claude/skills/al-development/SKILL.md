---
name: al-development
description: Build the Business Central extension from the approved PRD in this demo folder — write the AL code, optionally write and run tests and write a user guide with screenshots, compile with the four analyzers, and publish to the sandbox in app/.vscode/launch.json, end to end without prompts. Use after the PRD is approved and the user chose to begin development (requirements-docs Step 8).
---

# Development: PRD → AL code → build → publish

This workflow has no git, no AL-Go, and no CI. The main app is in `app/`. The test app (if requested) is in `test/`. The two folders are separate because `alc.exe` compiles each `.al` file under the project folder, including subfolders.

## Inputs from requirements-docs Step 8

Before you start, these four answers are known:

| Answer | Effect |
|--------|--------|
| Dashboard: yes / no | Yes: `dashboard-builder` tracks the tasks below. No: no dashboard. |
| Begin development: yes | This skill runs. |
| Tests: yes / no | Yes: do the steps marked **[Tests]**. No: skip them. |
| User guide: yes / no | Yes: do Step 8 **[User guide]**. No: skip it. |

## Run end to end without prompts

The user authorized this workflow, in this folder, to run from the first step to the last without a question:

- Do not ask for confirmation before you write code, build, publish, or run tests.
- Publish to the environment in `app/.vscode/launch.json` without a separate approval. This authorization is for that environment only. Do not publish to a different environment.
- When something fails, fix it and continue. Do not stop to ask.
- Stop early only if the same failure stays after 5 fix attempts, or if the environment cannot be reached. Then report what is done, what failed, and the error text.
- The only interaction is the Entra sign-in window that opens on the first publish or symbol download. The token caches, so later calls are silent.
- Do not run git commands. This folder is not under git.

## Publish target

Read these values from `app/.vscode/launch.json` (the first configuration) at the start of each run. Do not copy them into other files.

| launch.json property | Use |
|----------------------|-----|
| `environmentType` | `environmentType` for the AL MCP tools |
| `environmentName` | `environmentName` for the AL MCP tools |
| `tenant` | `tenant` for the AL MCP tools |
| `schemaUpdateMode` | `schemaUpdateMode` for `al_publish` |
| `startupObjectId`, `startupObjectType` | The page to give in the final report |

## Steps

### 1. Prepare

1. Read the approved PRD, `app/app.json`, and `app/.vscode/launch.json`.
2. Update the app information in `app/app.json` before you write code:

   | Property | Value |
   |----------|-------|
   | `name` | The solution name from the PRD subtitle, for example "Support Contracts" (30 characters or fewer) |
   | `brief` | One sentence on what the extension does, from the PRD overview (for example "Support contract management for Business Central.") |
   | `description` | One or two sentences on the main features, from the PRD overview |

   Keep `id`, `publisher`, `idRanges`, `application`, `runtime`, and `features`. The bootstrap set `publisher`. Leave `version` at its current value. Step 5 bumps it. The `brief` and `description` follow the writing standard in `CLAUDE.md`.
3. If the dashboard is on, tell `dashboard-builder` that development has started.

### 2. Download symbols

1. If the AL MCP tools are not loaded, load them with ToolSearch (`+al`). The `.mcp.json` file in the repo root starts the server.
2. Call `al_addproject` with the full path of `app`. This is safe if the project is already loaded.
3. Call `al_downloadsymbols` with `projectPath` set to the full path of `app`, and the environment values from `launch.json`. The symbols go to `app/.alpackages/`.

### 3. Write the AL code

Write the objects in the order of the task list in requirements-docs Step 8 (enums, setup, one feature at a time, permission set, upgrade).

- Put each object in its own file in `app/src/`, named `<ObjectName>.<ObjectType>.al`. The reference sample uses this pattern, for example `SupportContract.Table.al` and `CustomerCardSupContracts.PageExt.al`.
- Use the object IDs and names in the PRD AL Object Summary.
- Use the fields, types, and relations in the PRD Data Model Overview.
- Use the exact message texts from the PRD user stories and edge cases, as `Label` variables.
- Give each table field a `Caption` and `DataClassification`. Give each page field and action a `ToolTip`. Set `ApplicationArea = All` and `UsageCategory` on the list and setup pages, so that they are in the BC search.
- Use `Validate` and `TestField`, `Insert(true)`, and `Modify(true)`, so that the triggers run.
- For No. Series, use codeunit "No. Series" (BC 24 and later), not the obsolete "NoSeriesManagement".
- Look at `reference/SupportContracts/src` for the coding style.

After each feature, run the build (Step 4). Fix the errors before you start the next feature. If the dashboard is on, update it once for each feature: the task status, the AL files made, and the build result.

### 4. Build

Run the build script in PowerShell from the repo root:

```powershell
./scripts/Build-App.ps1
```

- The script compiles `app/` with `alc.exe`, CodeCop, AppSourceCop, PerTenantExtensionCop, UICop, and `supporting-files/project.ruleset.json`.
- The gate is zero errors and no `AL1003`. Fix the errors in the code. Do not hide a rule in the ruleset unless the rule does not apply to a per-tenant extension. Add a justification for each rule you hide.
- Fix the warnings where the fix is small and safe.
- Do not use `al compile` or the AL MCP `al_build` to make the package. `al compile` does not load the analyzers (AL tools 18.0.43).
- If symbols are missing, run Step 2 again.

### 5. Publish the app

1. **Bump the build number.** Increase the **Build** part of the `app/app.json` `version` by one (`1.0.0.0` → `1.0.1.0`). The version in **Extensions** then shows which build is installed.
2. Build again (Step 4). The package is `.output/<Publisher>_<Name>_<Version>.app`.
3. Call `al_publish` with these values:
   - `appPath`: the full path of the package
   - `skipBuild`: `true`
   - `environmentName`, `environmentType`, `tenant`, `schemaUpdateMode`: from `launch.json`
   - `forceUpgrade`: `true`
4. If the publish fails, put the `app/app.json` version back to the value before the bump. Fix the cause and do this step again. The `app/app.json` version must agree with the last build that you published.
5. `launch.json` sets `schemaUpdateMode` to `ForceSync`. A schema change to this extension's tables publishes without a sync error. ForceSync can remove data in the changed fields in the sandbox. That is acceptable for a demo sandbox.

### 6. [Tests] Write the test app

1. Create the test app in `test/` (a sibling of `app/`, not inside it):
   - `test/app.json`: a new `id` (GUID), `name` "<App name> Test", the same `publisher`, `application`, and `runtime` as the main app, `idRanges` 50150–50199, and `"target": "Cloud"`.
   - Dependencies: the main app (its `id`, `name`, `publisher`, and `version` before the first bump), and the Microsoft test libraries "Library Assert", "Any", and "Test Runner". Add "Library Variable Storage" if the tests handle confirm or message dialogs.
   - Call `al_addproject` for `test`, then `al_downloadsymbols` for the test project. Get the dependency IDs and versions from the symbol file names that it downloads.
2. Write the tests in `test/src/`:
   - One test codeunit (`Subtype = Test`) for each critical path in the PRD NFR "Testing" row, and for the edge cases with an error message.
   - Use the `// [GIVEN]`, `// [WHEN]`, `// [THEN]` comment pattern and the `Assert` codeunit.
   - Put test data creation in a `<App> Library` codeunit.
   - Use handler functions (`ConfirmHandler`, `MessageHandler`) for dialogs.
   - Add a test permission set if the test objects need one.
3. Build the test app: `./scripts/Build-App.ps1 -Project test`. The script finds the main app package in `.output/`.

### 7. [Tests] Publish and run the tests

1. Publish the main app first (Step 5), then the test app with `al_publish` and the same environment values. Do not bump the test app version.
2. Call `al_run_tests` for each test codeunit, with the environment values from `launch.json`.
3. If a test fails, find the cause. Fix the app or the test, then build, bump, and publish again, and run the tests again.
4. If the Microsoft test toolkit is not installed on the environment, the test app does not publish. Record this in the final report and continue with Step 8. Do not try to install the toolkit.

### 8. [User guide] Write the user guide with screenshots

Do this step after the app is published (Step 5), so that the screenshots show the real pages.

1. Write `docs/user-guide/<App name> User Guide.md` for the end users of the extension:
   - A title, then a line with the published version, "Business Central Online", and the month and year.
   - An **Overview** section: what the extension does, in a short list.
   - One numbered section for each main task of the PRD features, in feature order. Each section has numbered steps ("Select the search icon, and enter **<page caption>**."), one screenshot or more, and the notes and edge cases that a user sees (the error messages from the PRD, in bold page and field captions).
   - Use the page, field, and action captions from the AL code. Follow the writing standard in `CLAUDE.md`.
2. Take the screenshots in the sandbox with the browser tool:
   - Load the browser tools with ToolSearch: Claude in Chrome (`mcp__claude-in-chrome__*`) or the built-in browser (`mcp__Claude_Browser__*`). Read the skill for that browser first, if one is listed.
   - Open a new tab at `https://businesscentral.dynamics.com/<tenant>/<environmentName>/`. If a sign-in page opens, ask the user to sign in in the browser, then continue. Do not type a password.
   - Open each page with the BC search, or add `?page=<page ID>` to the URL. Use the CRONUS demo data.
   - Take each screenshot with `save_to_disk: true`. Copy the saved file to `docs/user-guide/images/NN-<page-name>.<ext>` (for example `01-support-contracts.png`), and link it in the guide with a relative path.
   - Limit the browser actions to opening pages, selecting records, opening lookups, and entering values in the new fields of this extension. Do not post documents, delete records, or change setup outside this extension. If a screenshot needs one of those actions, use the wireframe image for it.
3. If no browser tool is available, or the sandbox does not open, use the wireframe PNG files from `docs/wireframes/` (link them as `../wireframes/<file>.png`). Put this note below the title: "> **Draft.** This guide uses wireframe images. Replace them with sandbox screenshots before you share this guide." If the guide mixes screenshots and wireframes, say which sections use wireframes, and add "(wireframe)" to the alt text of each wireframe image.
4. Read each image file and look at it. Retake a screenshot that shows a loading page, an error, or the wrong record.
5. If the dashboard is on, add the guide as a deliverable.

### 9. Final check and report

1. Check that each PRD user story has code, and that each object ID is in the `app/app.json` range.
2. If the dashboard is on, mark the tasks done and add the final activity entry.
3. Give the user a short report:
   - The objects made (count for each type) and the files in `app/src/` (and `test/src/`)
   - The build result: errors, warnings, and the analyzers that ran
   - The published version and the environment (`environmentName`, tenant)
   - The test results (pass and fail count), or "Tests not requested"
   - The user guide path and the count of screenshots and wireframe images, or "User guide not requested"
   - The link to open the environment: `https://businesscentral.dynamics.com/<tenant>/<environmentName>`
   - The PRD items that are not done, and each change to the plan
