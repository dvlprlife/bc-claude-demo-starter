---
title: "Product Requirements Document"
subtitle: "{{Solution Name}} — Business Central Per-Tenant Extension"
description: "Prepared For {{Customer Name}}"
title-note: "Version {{1.0}} — {{Draft}} | Per-Tenant Extension (PTE) | AL | BC {{application major}}.0 (Runtime {{runtime}}) | Source: Functional Requirements v{{1.0}}"
date: "{{Month YYYY}}"
---

<!--
PRD TEMPLATE — modeled on reference/SupportContracts/docs/ProductRequirements v1.0.md

Audience: the delivery team (consultants, developers, testers). It translates the FRD into AL
objects, data structures, user stories, and edge cases.

Rules:
- Write the FRD first. Each PRD feature cites the FRD IDs it implements ("FRD Reference").
- Take the BC version, runtime, and object ID range from app.json ("application", "runtime",
  "idRanges"). Do not invent them.
- IDs: F<n> features, US-<f>.<n> user stories, EC-<f>.<n> edge cases, NFR-n, OQ-n.
- Each feature has: Description, a field or value table, a wireframe (when the feature has a
  page), User Stories (the first one is marked "(Primary)"), and an Edge Cases table.
- User stories use the personas from the Personas table: **As** ..., **I want to** ...,
  **so that** ... Then an "Acceptance Criteria" bullet list.
- Error, warning, and confirmation messages are quoted in italics: *"Message text."*
- A user story that implements an FRD recommendation names it in the title, for example
  "US-6.2: Batch Renew All Eligible Contracts (R-7)".
- Wireframes: docs/wireframes/NN-<page-name>.svg, exported to .png. See
  docs/templates/wireframe-style-guide.md.
- Remove all {{placeholders}} and all of these HTML comments from the final document.
-->

# Overview

This document translates the Functional Requirements Document (FRD v{{1.0}}) into a product-level specification for a Business Central Per-Tenant Extension built in AL. It defines the AL objects, data structures, user stories, and edge-case handling needed to implement the {{Solution Name}} solution for {{Customer Name}}.

The extension will allow {{Customer Name}} to {{summary of capabilities}} — all without leaving the BC environment.

# Product Goals & Success Metrics

<!-- One row for each FRD objective. Each metric is measurable (a count, a time, a click count, or
a percentage target). -->

| Goal | Metric |
|------|--------|
| {{Goal from OBJ-1}} | {{Measurable target}} |
| {{Goal from OBJ-2}} | {{Measurable target}} |

# Personas

| Persona | Role | Key Activities |
|---------|------|----------------|
| **{{Name}} — {{Persona Title}}** | {{Job title}} | {{Activities in this solution}} |
| **{{Name}} — {{Persona Title}}** | {{Job title}} | {{Activities}} |
| **Admin — System Administrator** | IT / BC Admin | Configures setup, assigns permission sets, manages number series |

# Feature 1 — {{Setup & Configuration}}

*FRD Reference: REQ-{{n}}, REQ-{{n}}*

## Description

{{One or two sentences on what the feature does and who uses it.}}

## Setup Fields

| Field | Type | Description |
|-------|------|-------------|
| {{Field}} | {{Code (No. Series) / Decimal / Boolean / Enum}} | {{Description}} |

## Wireframe: {{Page Name}}

![{{Page Name}} Page](./wireframes/{{NN}}-{{page-name}}.png)

## User Stories

### US-1.1: {{Story Title}} (Primary)

**As** {{Persona}},
**I want to** {{goal}},
**so that** {{benefit}}.

**Acceptance Criteria**

- {{Testable criterion}}
- {{Testable criterion}}

### US-1.2: {{Story Title}}

**As** {{the system | Persona}},
**I want to** {{goal}},
**so that** {{benefit}}.

**Acceptance Criteria**

- {{Criterion with the message text: *"Message text."*}}

### Edge Cases

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| EC-1.1 | {{Scenario}} | {{Expected behavior}} |
| EC-1.2 | {{Scenario}} | {{Expected behavior}} |

# Feature 2 — {{Feature Name}}

*FRD Reference: REQ-{{n}}, R-{{n}}*

## Description

{{Description}}

## {{Card Fields | Enum Values | Subpage Fields}}

| Field | Type | Description |
|-------|------|-------------|
| No. | Code | Auto-assigned from the configured number series. |
| {{Field}} | {{Type}} | {{Description}} |

<!-- For an enum, use this table instead:
| Value | Name | Caption |
|-------|------|---------|
| 0 | {{Name}} | {{Caption}} |
-->

## Wireframe: {{Page Name}}

![{{Page Name}} Page](./wireframes/{{NN}}-{{page-name}}.png)

## User Stories

### US-2.1: {{Story Title}} (Primary)

**As** {{Persona}},
**I want to** {{goal}},
**so that** {{benefit}}.

**Acceptance Criteria**

- {{Criterion}}

### Edge Cases

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| EC-2.1 | {{Scenario}} | {{Expected behavior}} |

<!-- For a feature with a status lifecycle, add these sections before User Stories:

## Status Transition Diagram

```
  ┌─────────┐         ┌─────────┐         ┌─────────┐
  │ {{A}}   │──────►  │ {{B}}   │──────►  │ {{C}}   │
  └─────────┘         └─────────┘         └─────────┘
       │                    │
       ▼                    ▼
  ┌───────────┐       ┌───────────┐
  │ {{D}}     │       │ {{D}}     │
  └───────────┘       └───────────┘
```

## Field Editability by Status

| Field | {{Status A}} | {{Status B}} | {{Status C}} |
|-------|:-----:|:------:|:-------:|
| {{Field}} | ✓ | Confirm | — |

For a process feature (posting, invoicing, batch jobs), add "Eligibility Criteria" (numbered
list) and a "{{Document}} Mapping" table (Target Field | Source).
-->

# Feature {{n}} — Security & Permissions

*FRD Reference: REQ-{{n}}*

## Description

A dedicated permission set controls access to all {{solution}} objects. Without the permission set, users cannot access {{solution}} pages, tables, or codeunits.

## Permission Set: "{{Permission Set Caption}}"

| Object Type | Object | Permission |
|-------------|--------|------------|
| Table | {{Table}} | Read, Insert, Modify, Delete |
| Page | {{Page}} | Execute |
| Codeunit | {{Codeunit}} | Execute |

## User Stories

### US-{{n}}.1: Grant {{Solution}} Access to a User (Primary)

**As** Admin,
**I want to** assign the "{{Permission Set Caption}}" permission set to users who need to {{activity}},
**so that** only authorized personnel can view and modify {{solution}} data.

**Acceptance Criteria**

- The permission set is visible in the BC permission set list.
- Assigning it to a user grants full access to all {{solution}} functionality.
- A user without the permission set receives a permission error when attempting to access any {{solution}} page.

### Edge Cases

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| EC-{{n}}.1 | User has the permission set but lacks read permissions on {{base table}} | The user can open {{solution}} pages but receives errors when the system reads {{base table}} data. The user needs sufficient base permissions alongside the {{solution}} permission set. |

# AL Object Summary

The following AL objects are required for the extension. Object IDs are within the assigned range of {{from}}–{{to}}.

<!-- Each object type has its own numbering from the start of the range. Include Install and
Upgrade codeunits and the permission set. Names follow AL naming limits (30 characters). -->

| Object Type | ID | Name | Purpose |
|-------------|----|------|---------|
| Enum | {{from}} | {{Name}} | {{Purpose}} |
| Table | {{from}} | {{Name}} Setup | Singleton setup record |
| Table | {{from+1}} | {{Name}} | {{Purpose}} |
| Page | {{from}} | {{Name}} Setup | Card page for setup configuration |
| Page | {{from+1}} | {{Name}} Card | Card page for detail view and actions |
| Page | {{from+2}} | {{Name}}s | List page for browsing and filtering |
| Codeunit | {{from}} | {{Name}} Install | Install logic (seed setup record, initialize defaults) |
| Codeunit | {{from+1}} | {{Name}} Upgrade | Upgrade logic for future version migrations |
| Codeunit | {{from+2}} | {{Name}} Mgt. | {{Business logic}} |
| Permission Set | {{from}} | {{Caption}} | Full RIMD access to all {{solution}} objects |

# Data Model Overview

## Table: {{Table Name}} ({{ID}})

| Field | Type | Key | Notes |
|-------|------|-----|-------|
| Primary Key | Code[10] | PK | Blank (singleton). |
| {{Field}} | {{Code[20] / Text[100] / Decimal / Date / Boolean / Enum (Name)}} | | {{Relation: Table. / FlowField from Table.}} |

## Table: {{Table Name}} ({{ID}})

| Field | Type | Key | Notes |
|-------|------|-----|-------|
| No. | Code[20] | PK | From number series. |
| {{Field}} | {{Type}} | | {{Notes}} |

# Non-Functional Requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR-1 | Compatibility | The extension must be compatible with BC Online (SaaS) version {{application major}}.0 and later. |
| NFR-2 | Deployment | Deployed as a Per-Tenant Extension (PTE). No dependency on other third-party extensions. |
| NFR-3 | Performance | {{Batch or volume target, for example: process up to N records within N seconds.}} |
| NFR-4 | Localization | English only for v1.0. Labels and messages should use AL caption properties to support future translation. |
| NFR-5 | Upgrade | The Upgrade codeunit must handle data migration for future schema changes. |
| NFR-6 | Code Standards | AL code must compile with zero errors with the CodeCop, AppSourceCop, PerTenantExtensionCop, and UICop analyzers (even though this is a PTE, AppSourceCop compliance is a best practice). |
| NFR-7 | Testing | Critical paths ({{list}}) should be covered by automated AL Test codeunits. |

# Open Questions & Decisions

<!-- Every point the request leaves unclear becomes an OQ with the design default in Decision.
Status: Open, Deferred, or Decided. -->

| # | Question | Status | Decision |
|---|----------|--------|----------|
| OQ-1 | {{Question}} | Open | {{Current design default. Confirm with {{Customer Name}}.}} |
| OQ-2 | {{Question}} | Deferred | {{Reason and target version}} |

# Requirement Traceability

<!-- One row for each PRD feature. Every FRD REQ appears in at least one row. Every FRD R that
the PRD implements appears in the FRD Recommendations column. -->

| PRD Feature | User Stories | FRD Requirements | FRD Recommendations | Priority |
|-------------|-------------|-------------------|----------------------|----------|
| F1: {{Name}} | US-1.1, US-1.2 | REQ-{{n}} | — | {{Priority}} |
| F2: {{Name}} | US-2.1 | REQ-{{n}} | R-{{n}} | {{Priority}} |
