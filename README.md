# BC Claude demo starter kit

Use this kit to repeat the demo on your own computer. You give Claude Code a customer request for Microsoft Dynamics 365 Business Central. Claude writes a Functional Requirements Document (FRD) and a Product Requirements Document (PRD) with wireframes. After you approve the PRD, Claude writes the AL extension, builds it, and publishes it to your sandbox.

**Download:** <https://github.com/dvlprlife/bc-claude-demo-starter/releases/latest/download/bc-claude-demo-starter.zip>

The latest release is on the [Releases page](https://github.com/dvlprlife/bc-claude-demo-starter/releases/latest).

## How it works

1. You point Claude Code at this kit.
2. Claude checks your computer and asks for your sandbox details.
3. Claude creates a new AL project folder from the kit.
4. You open Claude Code in the new folder and give it a customer request.
5. Claude writes the FRD and the PRD, then asks you to approve the PRD.
6. Claude asks three questions: a progress dashboard, begin development, and automated tests.
7. Claude writes the code, builds it, and publishes it to your sandbox without more questions.

## Before you start

You need these items.

| Item | Notes |
|------|-------|
| Windows 10 or 11 | The scripts use PowerShell and Microsoft Edge. |
| Claude Code | Install it from <https://claude.com/claude-code>. You need a Claude subscription or an API account that includes Claude Code. |
| .NET 8 SDK | `winget install Microsoft.DotNet.SDK.8` |
| AL tools, version 18 or later | `dotnet tool install --global Microsoft.Dynamics.BusinessCentral.Development.Tools` |
| Microsoft Edge | Converts the wireframes to PNG images. |
| A Business Central Online **sandbox** | Do not use a production environment. The demo can remove data in the sandbox. |
| Permission to publish extensions | Your user in the sandbox needs the **D365 EXTENSION MGT** permission set, or **SUPER**. |

Optional items:

- **Visual Studio Code with the AL Language extension.** Use it to look at the code. Claude does not need it.
- **Automated tests.** The sandbox needs the Microsoft test framework apps (Test Runner, Any, Library Assert). If they are not installed, Claude tells you and continues without the tests.
- **Progress dashboard.** It is a page on claude.ai. Claude offers it only when your Claude Code session can publish artifacts.

Claude checks the prerequisites for you. If the .NET SDK or the AL tools are missing, Claude offers to install them. Claude installs them only when you agree. Windows can show an administrator prompt for the .NET SDK. Approve it. You install Claude Code and Microsoft Edge yourself.

Find these values before you start:

- **Tenant:** the tenant ID (a GUID) or the domain, for example `contoso.onmicrosoft.com`.
- **Sandbox environment name:** for example `Sandbox`.
- **Business Central version:** for example 28.

In Business Central, open **Help & Support** (the **?** menu) to see these values. The Business Central URL also shows the tenant and the environment: `https://businesscentral.dynamics.com/<tenant>/<environment>/`.

## Step 1: Create the project

1. Download the kit zip file.
2. Open a terminal (PowerShell) in your `Downloads` folder, or in the folder where you extracted the kit.
3. Start Claude Code:

   ```powershell
   claude
   ```

4. Tell Claude where the kit is. Use one of these prompts:

   - From the zip file:
     > Create a new Business Central demo project from the starter kit in `Downloads\bc-claude-demo-starter.zip`. Follow BOOTSTRAP.md.
   - From the extracted folder:
     > Create a new Business Central demo project from the starter kit in `C:\Users\<you>\Downloads\bc-claude-demo-starter`. Follow BOOTSTRAP.md.
   - From the download URL:
     > Download the BC Claude demo starter kit from `https://github.com/dvlprlife/bc-claude-demo-starter/releases/latest/download/bc-claude-demo-starter.zip` and create a new Business Central demo project. Follow BOOTSTRAP.md.

   If you start Claude Code in the kit folder, this prompt is sufficient: "Create a new project."

5. Answer Claude's questions: the project folder, the publisher, the sandbox name, the tenant, and the version. Say "use the defaults" for the values that have a default.
6. Claude creates the project folder and tells you the next steps.

## Step 2: Open the project and check the setup

Claude loads the project skills and the AL tools only when Claude Code starts in the project folder.

1. Close Claude Code (`/exit`).
2. Start it in the new project folder:

   ```powershell
   cd "C:\Users\<you>\Documents\AL\BCDemo"
   claude
   ```

3. If Claude Code asks you to approve the `al` MCP server, approve it.
4. Type:

   > Check the setup.

   A browser window opens. Sign in with your Business Central user. Claude downloads the symbols from the sandbox and builds the empty app. Fix each problem that Claude reports before you continue.

## Step 3: Run the demo

1. Give Claude a customer request. Write it as the customer would. For example:

   > Here is a request from Fabrikam: they want to track equipment loans to customers, with due dates and a late fee invoice. Create the FRD and PRD.

2. Claude writes these files:
   - `docs/request.md`: your request, as given
   - `docs/FunctionalRequirements v1.0.md`: the FRD, in business language
   - `docs/ProductRequirements v1.0.md`: the PRD, with the AL objects, user stories, and edge cases
   - `docs/wireframes/`: the page wireframes
3. Read the PRD. Ask for changes if necessary, for example "Add a maximum loan period to the setup page." Claude makes a new version (v1.1).
4. When the PRD is correct, type:

   > The PRD is approved.

5. Answer the three questions:
   - Do you want a progress dashboard?
   - Do you want to begin development now?
   - Do you want automated tests?
6. Claude writes the AL code in `app/src/`, builds it with the code analyzers, and publishes it to your sandbox. Claude gives you a report and a link to the sandbox.
7. Open Business Central and look at the new pages.

Claude Code can ask for permission before it runs a command or edits a file. Select the option that allows the action for this project, so that the development step runs with fewer prompts.

## Run the demo again

Type:

> Reset the demo.

Claude removes the documents, the wireframes, and the code from the project folder. Claude also gives you the steps to remove the extension from the sandbox, if the AL tools cannot remove it. Start a new Claude Code session before the next request.

## What is in the kit

| Path | Content |
|------|---------|
| `README.md` | This guide |
| `BOOTSTRAP.md` | The instructions that Claude follows to create a project |
| `New-BCDemoProject.ps1` | The script that creates the project and checks the prerequisites |
| `CLAUDE.md` | Tells Claude that this folder is the kit, not a project |
| `template/` | The project that the script copies |

The `template/` folder contains:

| Path | Content |
|------|---------|
| `CLAUDE.md` | The project instructions for Claude |
| `.claude/skills/` | The three workflows: `requirements-docs`, `al-development`, and `reset-demo` |
| `.claude/agents/dashboard-builder.md` | The agent that makes the progress dashboard |
| `.mcp.json` | Starts the AL MCP server (symbols, publish, and test runs) |
| `app/` | The AL app: `app.json`, `src/`, and `.vscode/launch.json` (your sandbox) |
| `docs/templates/` | The FRD and PRD templates and the wireframe style guide |
| `reference/SupportContracts/` | A finished sample: FRD, PRD, wireframes, and AL code |
| `scripts/` | Build, wireframe export, and reset scripts |
| `supporting-files/` | Code analysis rules, the starting `app.json`, and the dashboard page |

## Troubleshooting

| Problem | What to do |
|---------|------------|
| "running scripts is disabled on this system" | Claude runs the scripts with `-ExecutionPolicy Bypass`. If you run a script yourself, use the same option, or run `Unblock-File` on the project files. |
| The `al` command is not found | Install the AL tools (see "Before you start"), then open a new terminal. |
| Claude does not know the skills | Start Claude Code in the project folder, not in the kit folder. |
| The sign-in fails or uses the wrong account | Ask Claude to sign out of the AL tools and sign in again. |
| The publish fails with a permission error | Give your user the **D365 EXTENSION MGT** permission set in the sandbox. |
| The symbols do not match the sandbox version | Ask Claude to set `application` and `runtime` in `app/app.json` for your version, and to copy the file to `supporting-files/app.baseline.json`. |
