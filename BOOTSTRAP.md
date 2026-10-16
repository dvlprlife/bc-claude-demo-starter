# Bootstrap: create a Business Central demo project

These instructions are for Claude Code. A user who attended the demo points Claude at this starter kit (a folder, a zip file, or a download URL) and asks for a new project. Do these steps in order.

The kit folder is the folder that contains this file, `New-BCDemoProject.ps1`, and `template/`. Do not change the files in the kit folder.

## 1. Get the kit

- **Folder:** use it as it is.
- **Zip file:** extract it to a new, empty folder next to the zip (for example `Downloads\bc-claude-demo-starter`). Use `Expand-Archive`.
- **URL:** download the zip with `Invoke-WebRequest` to a new, empty folder in the user's `Downloads` folder, then extract it there. Tell the user the URL and the folder before you download.

After you extract a zip, run `Get-ChildItem <kit> -Recurse -File | Unblock-File`. Windows marks files from the internet, and PowerShell can block marked scripts.

Find the folder that contains `BOOTSTRAP.md`. The zip can have one extra folder level.

## 2. Check the prerequisites

Run in PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<kit>\New-BCDemoProject.ps1" -CheckOnly
```

If an item is marked `MISSING`, list the missing items and offer to install them. Ask one question for all of them, for example: "The .NET 8 SDK and the AL tools are missing. Do you want me to install them now?" Install only when the user agrees.

| Item | Install command |
|------|-----------------|
| .NET SDK (dotnet) | `winget install --id Microsoft.DotNet.SDK.8 --exact --accept-package-agreements --accept-source-agreements` |
| AL tools (al) | `dotnet tool install --global Microsoft.Dynamics.BusinessCentral.Development.Tools` |
| AL tools version 18 or later | `dotnet tool update --global Microsoft.Dynamics.BusinessCentral.Development.Tools` |
| Microsoft Edge | Do not install it. Tell the user to install Microsoft Edge. Only the wireframe images need it. |

Install in this order:

1. **.NET SDK.** Tell the user that Windows can show an administrator prompt, and that they must approve it. If `winget` is not available, give the user the download page, <https://dotnet.microsoft.com/download/dotnet/8.0>, and stop until they install it.
2. **AL tools.** A new install of .NET is not on the PATH of this session. Use the full path for the `dotnet` command: `& "$env:ProgramFiles\dotnet\dotnet.exe" tool install --global Microsoft.Dynamics.BusinessCentral.Development.Tools`.
3. Run the check again. A new install of the AL tools is also not on the PATH of this session, so the check can show `MISSING` for them. If the install command succeeded, continue. The restart in Step 5 loads the new PATH.

If the user does not want the installs, give them the commands from the table and continue with Step 3. The project is created, but the build and publish steps need the tools. Continue with Step 3 when only Edge is missing.

## 3. Collect the project values

Ask the user for these values in one message. Show the default for each value. The user can accept the defaults with "use the defaults".

| Value | Default | Notes |
|-------|---------|-------|
| Project folder | `<Documents>\AL\BCDemo` | Must be new or empty. Do not use the kit folder. |
| Project name | `BCDemo` | 30 characters or fewer. Claude changes the app name to the solution name when development starts. |
| Publisher | (none, required) | The company or person name. Do not use `\ / : * ? " < > |`. |
| Sandbox environment name | (none, required) | The name of a Business Central Online **sandbox**, for example `Sandbox`. |
| Tenant | (none, required) | The Microsoft Entra tenant ID (a GUID) or domain, for example `contoso.onmicrosoft.com`. |
| BC major version | `28` | The version of the sandbox. Use 28 if the user does not know. The app installs on this version and later versions. |
| Object ID range | `50100`–`50149` | The test app uses `50150`–`50199`. |

Help the user find the values:

- In Business Central, open **Help & Support** (the **?** menu). The page shows the tenant ID, the environment name, and the version.
- The Business Central URL also shows them: `https://businesscentral.dynamics.com/<tenant>/<environment>/`.

Do not accept a production environment. The demo publishes with `ForceSync`, which can remove data.

## 4. Create the project

Run in PowerShell, with the values from Step 3:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<kit>\New-BCDemoProject.ps1" `
    -Destination "<project folder>" -ProjectName "<project name>" -Publisher "<publisher>" `
    -EnvironmentName "<environment>" -Tenant "<tenant>" -BCVersion <version> -IdFrom <from> -IdTo <to>
```

The script copies `template/` to the project folder, makes a new app ID, and fills in `app/app.json`, `app/.vscode/launch.json`, `supporting-files/app.baseline.json`, and `CLAUDE.md`. If the script fails, fix the cause (for example a folder that is not empty) and run it again.

Do not run git commands in the project folder. The demo does not use git.

## 5. Hand over to the user

The project's skills, agent, `CLAUDE.md`, and AL MCP server load only when Claude Code starts in the project folder. Tell the user these steps:

1. Close this Claude Code session (`/exit`).
2. Open the project:

   ```powershell
   cd "<project folder>"
   claude
   ```

3. If Claude Code asks to approve the `al` MCP server from `.mcp.json`, approve it.
4. Type: `Check the setup.` Claude downloads the symbols from the sandbox and builds the empty app. A browser window opens for the Microsoft sign-in.
5. Give Claude a customer request, for example: `Here is a request from Fabrikam: they want to track equipment loans to customers, with due dates and a late fee invoice. Create the FRD and PRD.`

Then give a short summary: the project folder, the values used, and any prerequisite that is still missing.
