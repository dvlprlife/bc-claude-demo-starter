# {{PROJECT_NAME}} — Business Central demo project

This folder is a base AL project for Microsoft Dynamics 365 Business Central. It was made from the BC Claude demo starter kit. A customer request comes in. We write a Functional Requirements Document (FRD) and a Product Requirements Document (PRD) for it. After the user approves the PRD, we build the extension and publish it to the sandbox.

## Check the setup

When the user asks to check the setup (for example "check the setup" or "test the connection"), do these steps without more questions:

1. Load the AL MCP tools with ToolSearch (`+al`). If they are not available, tell the user to restart Claude Code in this folder and approve the `al` MCP server.
2. Call `al_addproject` with the full path of `app`.
3. Call `al_downloadsymbols` for `app`, with `environmentName`, `environmentType`, and `tenant` from `app/.vscode/launch.json`. A browser window opens for the Entra sign-in.
4. Run `./scripts/Build-App.ps1`. An empty app builds with zero errors.
5. Report the symbols downloaded, the build result, and any problem with its fix. Do not publish during this check.

## When a request is given

Use the `requirements-docs` skill (`.claude/skills/requirements-docs/SKILL.md`):

1. Save the request to `docs/request.md`.
2. Write the FRD from `docs/templates/FunctionalRequirements-template.md`.
3. Design the AL objects and make the wireframes.
4. Write the PRD from `docs/templates/ProductRequirements-template.md`.
5. Cross-check the two documents and ask the user to approve the PRD.

Do not set up a dashboard during these steps. Do not write AL code until the user approves the PRD.

## After the PRD is approved

Ask these questions in this order (requirements-docs Step 8):

1. "Do you want a progress dashboard for the development of this project?" (only if the Artifact tools are available)
2. "Do you want to begin development now?"
3. If development is yes: "Do you want automated tests created for this extension?"
4. If development is yes: "Do you want a user guide with screenshots after the extension is published?"

If the dashboard answer is yes, the project agent `dashboard-builder` (`.claude/agents/dashboard-builder.md`) creates a dashboard of the development tasks. Then the `al-development` skill (`.claude/skills/al-development/SKILL.md`) runs.

These rules replace any global "progress dashboard for long tasks" rule for this project.

## Development runs end to end

After the four answers, development goes from the first step to the last without prompts: write the AL code, build, publish, and (if requested) write and run the tests and write the user guide.

- The user authorized publishing to the environment in `app/.vscode/launch.json` (`environmentName`, `environmentType`, `tenant`, `schemaUpdateMode`) without a separate approval. This authorization is for that environment only.
- Build: `./scripts/Build-App.ps1` (main app in `app/`) and `./scripts/Build-App.ps1 -Project test` (test app in `test/`). The script calls `alc.exe` with CodeCop, AppSourceCop, PerTenantExtensionCop, and UICop. Zero errors and no `AL1003` is the gate.
- Publish: the AL MCP server (`.mcp.json`), tool `al_publish`, with the prebuilt package (`skipBuild: true`). Bump the Build part of the `app/app.json` version before each publish. Put the version back if the publish fails.

## Reset the demo

When the user asks to reset the project or the demo, use the `reset-demo` skill (`.claude/skills/reset-demo/SKILL.md`). The request is the approval. Do not ask again.

1. Remove the test app and the extension from the environment in `app/.vscode/launch.json`. If the AL MCP server has no tool for this, give the user the Extension Management steps.
2. Run `./scripts/Reset-Demo.ps1`. It removes the documents, wireframes, AL source, test app, packages, and dashboard anchor, and restores `app/app.json` from `supporting-files/app.baseline.json`.

## No git

This folder is not under git control, and the demo needs no version tracking. Do not run git commands, and do not make commits, branches, pull requests, or releases. Tell `dashboard-builder` to leave the repo, branch, and version fields blank.

## Writing standard

All documents, notes, and app text (FRD, PRD, user guide, `app.json` brief and description, captions, tooltips, and messages) follow **Simplified Technical English (based on ASD-STE100)** and the **no-absolutes** rule.

- **No absolutes, universal qualifiers, or warranty language** about how the software behaves: do not use *never*, *always*, *every*, *all*, *exactly*, *fully*, *ensures*, *guarantees*, or *100%* in a claim about behavior. Write "it does not delete it", not "it never deletes it". This rule outranks the others, including active voice.
- Two exemptions: a **directive to the reader** ("Use a sandbox, not production") and a **validation rule the software enforces** ("Splits must total 100%").
- STE basics: short sentences (20 words for an instruction, 25 for a description), one instruction for each sentence, active voice, imperative instructions, present tense, no *via*, *in order to*, *utilize*, *prior to*, *e.g.*, *i.e.*, or *etc.*
- Quoted requirement text from a spec (an FRD's acceptance criteria) stays as written.

## Reference sample

`reference/SupportContracts/` holds the model. It is not part of the build.

- `docs/FunctionalRequirements v1.0.md` — the FRD structure and tone
- `docs/ProductRequirements v1.0.md` — the PRD structure and depth
- `docs/wireframes/` — the wireframe style
- `src/` — the AL file naming and coding style

## Project facts

- Read `app/app.json` for the BC version (`application`), `runtime`, publisher, and object ID range (`idRanges`). The PRD and the code use these values. The test app uses IDs 50150–50199.
- Target: Business Central Online, Per-Tenant Extension.
- `scripts/Export-Wireframes.ps1` converts wireframe SVG files to PNG files with Microsoft Edge in headless mode. Do not assume that Python, Node, or pandoc are installed.

## Folder layout

| Path | Content |
|------|---------|
| `app/` | The main AL app: `app.json`, `src/`, `.alpackages/` (symbols), `.vscode/launch.json` (the sandbox) |
| `test/` | Test app (only when tests are requested). It is a sibling of `app/` because `alc.exe` compiles each `.al` file under a project folder. |
| `docs/templates/` | FRD and PRD templates, wireframe style guide, wireframe SVG templates |
| `docs/` | The FRD, PRD, and `request.md` for the current request |
| `docs/wireframes/` | Wireframe SVG and PNG files for the PRD |
| `reference/SupportContracts/` | The reference sample (documents, wireframes, AL source) |
| `.output/` | Built `.app` packages |
| `.dashboard/` | The dashboard anchor (only when a dashboard is used) |
| `supporting-files/project.ruleset.json` | Code analysis rules |
| `supporting-files/app.baseline.json` | The `app/app.json` of a fresh demo (the reset restores it) |
| `supporting-files/dashboard/template.html` | The dashboard page that `dashboard-builder` publishes |
| `scripts/` | Build, wireframe export, and reset scripts |
| `.mcp.json` | AL MCP server (symbols, publish, test runs) |
