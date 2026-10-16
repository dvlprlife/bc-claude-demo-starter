# Wireframe Style Guide

The PRD wireframes copy the style of the sample in `reference/SupportContracts/docs/wireframes`. Each wireframe is a hand-written SVG that looks like a Business Central web client page. Numbered callouts mark the parts of the page that the PRD specifies. A Notes panel at the bottom explains each callout and gives its trace IDs.

## Files

- Source: `docs/wireframes/NN-<page-name>.svg`. `NN` is a two-digit sequence number in PRD order (`01`, `02`, ...). Use lowercase kebab-case for the page name.
- Image: `docs/wireframes/NN-<page-name>.png`. The PRD embeds the PNG file.
- Starting points: `docs/templates/wireframes/card-page-template.svg` and `list-page-template.svg`.
- To make the PNG files, run `./scripts/Export-Wireframes.ps1`. The script uses Microsoft Edge in headless mode at 2x scale.

## Which pages get a wireframe

Make one wireframe for each new page that a user sees:

- The list page and the card page of each main record
- The setup page
- Each change to a standard BC page (for example, a new action or FactBox on the Customer Card)
- Each confirmation dialog or request page that is part of a process (for example, a batch run)

Subpages are shown inside the card wireframe. They do not get a separate file.

## Page frame

Keep these parts the same on each wireframe. The template files contain them.

| Part | Specification |
|------|---------------|
| Canvas | Width 1060 px. Set the height to fit the content. Background `#fff`. |
| Font | `Segoe UI, -apple-system, sans-serif` |
| Header bar | 40 px high, `#1a3050`, text "Dynamics 365 Business Central", "Environment: dev", user initials "PA" |
| Company bar | 36 px high, "CRONUS USA, Inc." and role center menus in `#0078d4` |
| Title and action bar | 36 px high, `#faf9f8`, page caption at 15 px semibold, then actions. Show the primary action of the page in semibold. |
| FastTab header | 28 px high, `#f3f2f1`, "▾  General" (or another FastTab name) |

## Controls

| Control | How to draw it |
|---------|----------------|
| Field caption | 12 px, `#605e5c` |
| Editable field | Rectangle with `rx="3"`, stroke `#c8c6c4`, 22 px high |
| Lookup value | Value text in `#0078d4` |
| Read-only value | Value text in `#323130`, no box |
| Decimal | Right-aligned value (`text-anchor="end"`) |
| Option or enum | Box with "▾" at the right end |
| Boolean | Toggle: rounded rectangle 36 x 16, `#0078d4` when on, `#c8c6c4` when off |
| Status | Pill with `rx="10"`. Green `#107c10` for active, gray `#605e5c` for draft, red `#a4262c` for expired or cancelled, all at 12% opacity behind the text |
| List header | 30 px high, `#faf9f8`, 11.5 px semibold `#605e5c` |
| List row | 34 px high. Selected row `#cce4f7`. No. column underlined in `#0078d4`. |

Use demo data from the CRONUS company: customers such as Adatum Corporation, Trey Research, School of Fine Art, Alpine Ski House, and Relecloud.

## Callouts and notes

- A callout is a red circle (`#d13438`, radius 11) with a white number. Put it 14 px to the right of the item it marks.
- Number the callouts from top to bottom, then left to right.
- The Notes panel starts below the page content. Background `#faf9f8`, title "Notes" at 13 px bold.
- Each note has a small red circle (radius 9), then the text at 11.5 px in `#605e5c`.
- Write each note in this format: `<Item>: <behavior or validation> — <trace IDs>`. Example: `Renewal Item No.: lookup to Item table; only non-blocked items accepted — REQ-10, US-1.1, EC-1.1`.
- Keep each note on one line. Space the notes 24 px apart.

## Checks before you embed a wireframe

1. Each callout has a note, and each note has a callout.
2. Each trace ID in a note exists in the FRD or PRD.
3. Each field on a card wireframe is in the PRD field table for that feature.
4. You exported the PNG file again after the last change to the SVG file.
