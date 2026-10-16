# Requirements documents

This folder holds the requirements documents for the current request.

| File | Purpose |
|------|---------|
| `request.md` | The customer request, as given |
| `FunctionalRequirements v1.0.md` | FRD: what the customer needs, in business language |
| `ProductRequirements v1.0.md` | PRD: how the extension delivers it (AL objects, user stories, edge cases) |
| `wireframes/` | Page wireframes that the PRD embeds |
| `templates/` | The templates and the wireframe style guide |

## How to start

Give Claude the request, for example:

> Here is a request from Fabrikam: they want to track equipment loans to customers, with due dates and a late fee invoice. Create the FRD and PRD.

Claude uses the `requirements-docs` skill to make the documents. To make the wireframe images again after a change, run:

```powershell
./scripts/Export-Wireframes.ps1
```

## Document flow

1. The FRD comes first. The customer reviews it.
2. The PRD translates each FRD requirement (REQ-n) and recommendation (R-n) into features, user stories, and edge cases.
3. The traceability tables at the end of each document link the two.
4. When you approve the PRD, Claude asks four questions: a dashboard (yes or no), begin development (yes or no), automated tests (yes or no), and a user guide with screenshots (yes or no).
5. Development then runs without more questions. Claude writes the AL code in `app/src`, builds it, and publishes it to the sandbox in `app/.vscode/launch.json`. If you asked for tests, Claude also writes and runs them. If you asked for a user guide, Claude writes it in `docs/user-guide/` with screenshots from the sandbox.
6. To run the demo again, say "reset the demo". Claude removes the extension from the sandbox and removes the documents and code from this folder.
