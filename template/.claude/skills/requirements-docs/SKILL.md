---
name: requirements-docs
description: Turn a customer request for a Business Central extension into a Functional Requirements Document (FRD) and a Product Requirements Document (PRD) with wireframes, modeled on the Support Contracts reference sample. Use when the user gives a new feature or customization request, asks for an FRD or PRD, asks to revise one, or approves the PRD (Step 8 asks the dashboard, development, and test questions, then hands off to al-development).
---

# Request → FRD → PRD

Use this workflow when a request for a Business Central solution comes in. The outputs go in `docs/`:

| Output | Path |
|--------|------|
| FRD | `docs/FunctionalRequirements v<major>.<minor>.md` |
| PRD | `docs/ProductRequirements v<major>.<minor>.md` |
| Wireframes | `docs/wireframes/NN-<page-name>.svg` and `.png` |

The templates in `docs/templates/` show the required structure. The reference sample is `reference/SupportContracts/docs`. Read the sample FRD and PRD before you write the first document in a session. Match their depth, tone, and table shapes.

## No dashboard during the document phase

Do not set up a progress dashboard for Steps 1–7. This project setting replaces any global "progress dashboard for long tasks" rule for the document phase. The dashboard is a development tool. Step 8 asks the user if they want one.

For each unclear point in the request, take a sensible default and continue. Record the point and the default in the PRD Open Questions table. Do not stop and wait for an answer.

This folder does not use git. Do not run git commands, make commits, or create branches.

## Step 1 — Capture and analyze the request

1. Save the request text, as given, to `docs/request.md` with the date. Do not edit the request text.
2. Read `app/app.json`. Record `application` (BC version), `runtime`, `idRanges`, `name`, and `publisher`. The PRD uses these values.
3. Find these items in the request:
   - The customer name. If it is missing, use "the customer" and add a question.
   - Each explicit need. Each one becomes a REQ with Source "Customer Request".
   - The items that are necessary for the needs to work, such as a setup table, a number series, a status lifecycle, list and card pages, and a permission set. Each one becomes a REQ with Source "Recommendation".
   - Good ideas that the customer did not ask for. Each one becomes an R-n recommendation.
   - Items that are clearly outside the request. These go in Out of Scope.
   - Unclear points. These go in PRD Open Questions with the default you take.

## Step 2 — Write the FRD

Copy `docs/templates/FunctionalRequirements-template.md` to `docs/FunctionalRequirements v1.0.md` and fill it in.

- Audience: the customer. Use business language. Do not name AL objects, IDs, or field types.
- Keep the section order of the template.
- Number REQs across the whole document. Put Security & Permissions and Reporting REQs after the Recommendations section, as in the sample.
- Write one business process flow for each main process.
- Each recommendation has a **Recommendation** paragraph and a **Business Value** paragraph.
- Each REQ and R is in the traceability appendix with Source and Priority.
- Write acceptance criteria that a tester can check.

## Step 3 — Review the FRD

Check these items before you write the PRD:

- Each explicit need in the request maps to a REQ.
- No REQ marked "Customer Request" goes beyond the request.
- Each REQ and R is in the traceability appendix.
- No `{{placeholder}}` or template comment is left.

## Step 4 — Design the AL objects and data model

- Use the ID range from `app/app.json`. Number each object type from the start of the range: the first table, the first page, and the first codeunit each get the first ID.
- Include Install and Upgrade codeunits and a permission set.
- Use standard BC patterns: a singleton setup table with a blank primary key, No. Series for document numbers, enums for fixed values, table relations to standard tables, and FlowFields for read-only data from other tables.
- Object names have a maximum of 30 characters.
- Use the AL types in the data model (`Code[20]`, `Text[100]`, `Decimal`, `Date`, `Boolean`, `Enum (<Name>)`).

## Step 5 — Make the wireframes

Follow `docs/templates/wireframe-style-guide.md`.

1. Copy the card or list template from `docs/templates/wireframes/` to `docs/wireframes/NN-<page-name>.svg`.
2. Put the real captions, fields, actions, and CRONUS demo data on the page.
3. Add the callouts and the Notes panel with trace IDs (REQ, US, EC, R).
4. Run `./scripts/Export-Wireframes.ps1`.
5. Read each PNG file and look at it. Fix overlaps, clipped text, and empty space.

## Step 6 — Write the PRD

Copy `docs/templates/ProductRequirements-template.md` to `docs/ProductRequirements v1.0.md` and fill it in.

- Audience: the delivery team.
- Put the BC version and runtime from `app/app.json` in the title note.
- Make one feature section for each functional area of the FRD. Cite the FRD IDs under each feature heading.
- Each feature has a description, a field or value table, a wireframe (if it has a page), user stories, and an edge case table.
- The first user story of each feature is the primary story. Use the personas from the Personas table.
- Quote each error, warning, and confirmation message in italics.
- Each Open Question has the design default in the Decision column. Use the unclear points from Step 1.

## Step 7 — Cross-check

- Each FRD REQ is in the PRD Requirement Traceability table.
- Each FRD R that the PRD implements is in the FRD Recommendations column.
- Each object in the AL Object Summary has a data model table (tables) or a use in a feature (pages, codeunits).
- Each wireframe in the PRD exists as a PNG file.
- The ID ranges and BC version agree with `app/app.json`.
- Each object name in the AL Object Summary has 30 characters or fewer. Count the characters, including spaces and periods. Names like "Sales Order Sub. Support Class." (31) fail the build.

Give the user a short summary: the documents made, the count of REQs, Rs, features, and user stories, and the open questions with their defaults. Then ask the user to review and approve the PRD. Do not start development until the user approves it.

## Step 8 — PRD approved: questions, then development

When the user approves the PRD (for example "approved", "the PRD is good", or "proceed to development"), ask these questions in this order. Use the AskUserQuestion tool, with one question in each call. This project instruction replaces any global rule that says not to use AskUserQuestion for dashboard decisions.

1. **Dashboard:** "Do you want a progress dashboard for the development of this project?" Options: "Yes — create a dashboard" and "No — continue without one".
   - The dashboard is a claude.ai Artifact. It needs the Artifact and ArtifactData tools. If they are not in this session (check with ToolSearch for `Artifact`), do not ask this question. Tell the user in one line that the dashboard is not available in this session, and use "No".
2. **Development:** "Do you want to begin development now?" Options: "Yes — build and publish the extension" and "No — stop after the PRD".
   - If the answer is **No**, stop. If the dashboard answer was Yes, create the dashboard with the development tasks in the "To do" state, so that it is ready. Tell the user to say "begin development" when they are ready. When they say it, ask question 3 and continue.
3. **Tests:** ask this question only if the development answer is Yes. "Do you want automated tests created for this extension?" Options: "Yes — create and run tests" and "No — develop without tests".

After the three answers:

1. If the dashboard answer is **Yes**, have the `dashboard-builder` subagent create the dashboard before you write AL code. Give it:
   - The project name (`name` in `app/app.json`) and the PRD file name and version.
   - The current phase: "Development".
   - The development tasks from the list below. Each task names the PRD feature and the AL objects it covers. Leave out the test tasks if the tests answer is No.
   - The open questions from the PRD Open Questions table, each with its default.
   - The publish target: `environmentName` and `environmentType` from `app/.vscode/launch.json`.
   - This statement: "This folder is not under git control. There are no repos, branches, commits, PRs, CI runs, or releases. Leave those fields blank and do not track versions."

   Tell the user the dashboard URL once. Continue the same `dashboard-builder` agent with SendMessage for each update. Do not start a new one each time.
2. Use the `al-development` skill (`.claude/skills/al-development/SKILL.md`) with the three answers. From this point, development runs from end to end without prompts: code, build, publish, and (if requested) tests.
3. If the dashboard is on, check the `ANSWERS:` line of each dashboard-builder report. When the user answers a question on the page, apply the answer to the code and, if necessary, to the PRD. Do not stop development to wait for an answer.

### Development tasks from the PRD

Make the task list in this order. Use the AL Object Summary, the features, and the NFRs of the PRD.

1. Download symbols from the environment in `app/.vscode/launch.json`
2. Enums (one task for all enums)
3. Setup table, setup page, and Install codeunit
4. One task for each PRD feature, in feature order: its tables, pages, page extensions, and codeunits
5. Permission set
6. Upgrade codeunit
7. Build with the four analyzers (zero errors)
8. Publish to the environment in `app/.vscode/launch.json`
9. **[Tests]** Test app and test codeunits for the critical paths in the NFR "Testing" row
10. **[Tests]** Publish the test app and run the tests
11. Final check: each PRD user story is implemented, and each object ID is in the `app/app.json` range

## Revisions

When the user asks for a change to a finished document, increase the minor version (`v1.0` → `v1.1`). Make a new file and keep the old one. Update the `title-note` version, and the PRD "Source: Functional Requirements" version if the FRD changed.

## Writing style

The writing standard in `CLAUDE.md` applies: Simplified Technical English and the no-absolutes rule. These items are permitted because the sample uses them:

- "shall" and "should" in requirement statements.
- Fixed values and limits that the software enforces ("exactly three service levels", "A maximum of 3 contacts are allowed per contract").
- Numeric targets in the success metrics table.

Do not use *never*, *always*, *ensures*, or *guarantees* in descriptions of behavior.
