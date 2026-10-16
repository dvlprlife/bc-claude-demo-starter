---
title: "Functional Requirements Document"
subtitle: "{{Solution Name}} for Microsoft Dynamics 365 Business Central"
description: "Prepared for {{Customer Name}}"
title-note: "Document Version {{1.0}} — Status: {{Draft}}"
date: "{{Month YYYY}}"
---

<!--
FRD TEMPLATE — modeled on reference/SupportContracts/docs/FunctionalRequirements v1.0.md

Audience: the customer and the business stakeholders. Write in business language.
Do not name AL objects, object IDs, field types, or code. Those go in the PRD.

Rules:
- Keep the section order below. Do not rename sections.
- IDs: OBJ-n (objectives), REQ-n (requirements, numbered across the whole document),
  R-n (recommendations), A-n (assumptions), AC-n (acceptance criteria).
- Requirement statements use "shall" (mandatory) or "should" (preferred).
- Mark each REQ and R in the traceability appendix as "Customer Request" (it came from the
  request) or "Recommendation" (we added it). Priority: Must Have, Should Have, Nice to Have,
  or Deferred.
- Put features the customer did not ask for in Recommendations, not in Business Requirements,
  unless they are necessary for the requested features to work (for example a setup page or a
  number series). Those necessary additions are REQs with Source "Recommendation".
- Remove all {{placeholders}} and all of these HTML comments from the final document.
-->

# Executive Summary

{{Customer Name}} requires a solution within Microsoft Dynamics 365 Business Central Online to {{one-sentence business need}}. The solution will allow {{Customer Name}} to {{key capabilities}}. {{One or two sentences on the business benefit.}}

# Business Objectives

| ID | Objective |
|----|-----------|
| OBJ-1 | {{Objective that starts with a verb: Centralize, Provide, Reduce, Improve.}} |
| OBJ-2 | {{Objective}} |
| OBJ-3 | {{Objective}} |

# Scope

## In Scope

- {{Capability}}
- {{Capability}}
- Setup and configuration options
- {{List and detail views}}
- {{Basic reporting and filtering}}

## Out of Scope

- {{Item that is excluded, with the reason in parentheses if useful}}
- {{Item}} (see Recommendations for future consideration)

# Definitions

| Term | Definition |
|------|-----------|
| **{{Term}}** | {{Definition in business language.}} |
| **{{Term}}** | {{Definition}} |

# Business Requirements

<!-- Group requirements under functional areas (## headings). Number REQs across the whole
document, not inside each group. Use bullet lists for captured information, tables for fixed
value lists (for example statuses or levels), and numbered lists for system steps. -->

## {{Functional Area 1}}

### REQ-1: {{Requirement Title}}

Users shall be able to {{action}} within Business Central. Each {{record}} shall capture the following information:

- **{{Field}}**: {{Description}} (mandatory).
- **{{Field}}**: {{Description}} (default: {{value}}).

### REQ-2: {{Requirement Title}}

The solution shall support {{n}} {{values}}:

| {{Value Column}} | {{Description Column}} |
|------------------|------------------------|
| **{{Value}}** | {{Description}} |
| **{{Value}}** | {{Description}} |

### REQ-3: {{Status / Lifecycle Requirement, if the record has a lifecycle}}

| Status | Description |
|--------|-------------|
| **{{Status}}** | {{Description}} |

Status transitions:
- {{Status}} → {{Status}} ({{user action | automatic}})

## {{Functional Area 2}}

### REQ-4: {{Requirement Title}}

When a user {{trigger}}, the system shall:

1. {{Step}}
2. {{Step}}
3. {{Step}}

### REQ-5: Setup and Configuration

A centralized setup area shall allow administrators to configure:

- **{{Setting}}**: {{Description}}.

## Navigation and Usability

### REQ-6: {{List View}}

Users shall have access to a list view of all {{records}}, with filtering and sorting capabilities on key fields including:

- {{Field}}
- {{Field}}

### REQ-7: {{Detail View}}

{{Description of the card page and what users can edit.}}

### REQ-8: {{Navigation from a standard BC record, if relevant}}

{{Description}}

# Business Process Flows

<!-- One flow for each main process. Use a fenced code block with numbered steps, as in the
sample. Steps start with "User" or "System". -->

## {{Process Name}}

```
1. User {{action}}.
2. System {{action}}.
3. User {{action}}.
```

## {{Process Name}}

```
1. {{Step}}
2. {{Step}}
```

# Recommendations

The following recommendations go beyond the stated requirements and are suggested to enhance the solution's value. Each is optional and can be included or deferred based on {{Customer Name}}'s priorities.

## R-1: {{Recommendation Title}}

**Recommendation**: {{What we recommend and how it works.}}

**Business Value**: {{Why it helps the customer.}}

## R-2: {{Recommendation Title}} (Future Phase)

**Recommendation**: {{Description}}

**Business Value**: {{Description}}

# Security & Permissions

## REQ-{{n}}: Permission-Based Access

Access to {{solution}} functionality shall be controlled through Business Central's standard permission set model. A dedicated permission set shall be provided that grants users the ability to:

- {{Permission}}
- {{Permission}}

Administrators can assign this permission set to users or user groups as appropriate. Users without the permission set will not have access to {{solution}} pages or actions.

# Reporting

## REQ-{{n}}: {{List Filtering and Export}}

Users shall be able to filter the {{record}} list by any combination of {{fields}}. The filtered list shall be exportable to Excel using Business Central's standard export functionality.

# Assumptions & Constraints

| # | Assumption / Constraint |
|---|------------------------|
| A-1 | {{Customer Name}} uses Dynamics 365 Business Central Online (SaaS). The solution will be deployed as a per-tenant extension. |
| A-2 | {{Master data assumption}} |
| A-3 | The solution will be available in English only for the initial release. |
| A-4 | No integration with external systems is required for the initial release. |
| A-5 | Users will have appropriate Business Central licenses (Essentials or Premium). |

# Acceptance Criteria

<!-- One testable statement for each Must Have / Should Have requirement group. Write each
criterion as "A user can ..." or "When ..., the system ...". -->

| ID | Criteria |
|----|----------|
| AC-1 | {{Testable criterion}} |
| AC-2 | {{Testable criterion}} |

# Appendix: Requirement Traceability

| Requirement | Source | Priority |
|-------------|--------|----------|
| REQ-1: {{Title}} | Customer Request | Must Have |
| REQ-2: {{Title}} | Recommendation | Should Have |
| R-1: {{Title}} | Recommendation | Nice to Have |
| R-2: {{Title}} | Recommendation (Future) | Deferred |
