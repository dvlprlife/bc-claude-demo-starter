---
title: "Functional Requirements Document"
subtitle: "Support Contracts for Microsoft Dynamics 365 Business Central"
description: "Prepared for Acme Co."
title-note: "Document Version 1.0 — Status: Draft"
date: "March 2026"
---

# Executive Summary

Acme Co. requires a solution within Microsoft Dynamics 365 Business Central Online to manage customer support contracts. The solution will allow Acme Co. to create, track, and renew support contracts tied to their existing Business Central customers. Contracts will support multiple service levels, link to customer contacts, and provide automated renewal invoicing to reduce manual effort and improve contract lifecycle management.

# Business Objectives

| ID | Objective |
|----|-----------|
| OBJ-1 | Centralize support contract management within Business Central to eliminate external tracking tools. |
| OBJ-2 | Provide clear visibility into contract status, service level, and renewal dates. |
| OBJ-3 | Reduce administrative overhead by automating the annual renewal invoicing process. |
| OBJ-4 | Ensure contract-related contact information is readily accessible to support and sales teams. |

# Scope

## In Scope

- Support contract creation and management
- Linking contracts to existing Business Central customers
- Linking contracts to up to three customer contacts per contract
- Three defined service levels
- Contract start and end date tracking
- Auto-renewal toggle with automated renewal invoice creation
- Setup and configuration options
- Contract list and detail views
- Basic reporting and filtering

## Out of Scope

- Customer or contact master data creation (uses existing Business Central records)
- Support ticket or case management
- SLA response time enforcement or monitoring
- Integration with external helpdesk or CRM systems
- Email notifications or automated reminders (see Recommendations for future consideration)

# Definitions

| Term | Definition |
|------|-----------|
| **Support Contract** | An agreement between Acme Co. and a customer that defines the level of support services provided over a defined period. |
| **Service Level** | The tier of support provided under a contract (Standard, Expedited, or Full Service). |
| **Contract Contact** | A person associated with the customer who is designated as a point of contact for the support contract. Up to three contacts may be linked per contract. |
| **Auto-Renew** | A setting on a contract that, when enabled, triggers the automatic creation of a renewal sales invoice when the contract period ends. |
| **Renewal Invoice** | A sales invoice generated in Business Central to bill the customer for the upcoming contract period. |

# Business Requirements

## Support Contract Management

### REQ-1: Contract Creation

Users shall be able to create a new support contract record within Business Central. Each contract shall capture the following information:

- **Customer**: Link to an existing Business Central customer (mandatory).
- **Service Level**: Selection of one of three service tiers — Standard, Expedited, or Full Service (mandatory).
- **Start Date**: The date the contract coverage begins (mandatory).
- **End Date**: The date the contract coverage expires (mandatory).
- **Auto-Renew**: A toggle indicating whether the contract should be automatically renewed at the end of the contract period (default: off).
- **Contract Contacts**: Up to three contacts linked to the contract, selected from the customer's existing Business Central contacts.
- **Description / Notes**: Free-text field for any additional details or special terms.

### REQ-2: Service Levels

The solution shall support exactly three service levels:

| Service Level | Intended Use |
|---------------|-------------|
| **Standard** | Basic support coverage with standard response expectations. |
| **Expedited** | Enhanced support with prioritized response expectations. |
| **Full Service** | Comprehensive support with the highest level of coverage and response priority. |

Service levels shall be predefined and consistent across all contracts. The specific response time commitments or scope of each level are managed outside the system as part of Acme Co.'s operational policies; the system tracks which level has been contracted.

### REQ-3: Customer Linkage

Each support contract shall be linked to exactly one existing Business Central customer record. The customer's name, number, and key details should be visible on the contract for reference. If a customer is blocked or has an overdue balance, the contract can still be created, but this condition should be visible to the user (see Recommendation R-3).

### REQ-4: Contract Contacts

Each support contract shall allow the user to associate up to three contacts. These contacts must be existing Business Central contact records associated with the selected customer. The system shall enforce the maximum of three contacts per contract.

The purpose of contract contacts is to identify the individuals at the customer who are authorized to request support under the contract.

### REQ-5: Contract Dates

- The **Start Date** must be on or before the **End Date**.
- Contracts are intended to be annual (12-month periods), but the system shall not enforce a specific duration, allowing flexibility for partial-year or multi-year contracts.
- The system shall clearly display when a contract is active, upcoming, or expired based on the current date relative to the start and end dates.

### REQ-6: Contract Status

Each contract shall have a status to reflect its lifecycle stage:

| Status | Description |
|--------|-------------|
| **Draft** | Contract has been created but is not yet active. Can be freely edited. |
| **Active** | Contract is in effect. The current date falls within the start and end dates. Limited fields may be edited. |
| **Expired** | The contract end date has passed and the contract has not been renewed. |
| **Cancelled** | The contract was terminated before its natural end date. |

Status transitions:
- Draft → Active (user action to activate)
- Active → Expired (automatic when end date passes, or manual)
- Active → Cancelled (user action)
- Draft → Cancelled (user action)

### REQ-7: Contract Number Series

Each support contract shall be assigned a unique contract number using a Business Central number series. The number series shall be configurable in a setup area (see REQ-10).

## Auto-Renewal and Invoicing

### REQ-8: Auto-Renew Toggle

Each contract shall include an **Auto-Renew** field (on/off). When enabled, the system shall support automated creation of a renewal sales invoice as the contract approaches its end date.

### REQ-9: Renewal Invoice Creation

When a user initiates the renewal process (manually or via a scheduled action), the system shall:

1. Identify all active contracts with Auto-Renew enabled that are approaching their end date.
2. For each qualifying contract, create a draft **Sales Invoice** in Business Central linked to the contract's customer.
3. The sales invoice shall include a configurable renewal item and amount (see REQ-10).
4. After the renewal invoice is created, the contract's start and end dates shall be advanced by one year to reflect the new contract period.
5. The system shall record the date the contract was last renewed.

The renewal invoice is created as a **draft** (not posted), allowing Acme Co. staff to review and adjust before sending to the customer.

### REQ-10: Setup and Configuration

A centralized setup area shall allow administrators to configure:

- **Contract Number Series**: The number series used for assigning contract numbers.
- **Renewal Item No.**: The Business Central item to be used on renewal invoices (e.g., a service item representing the annual contract fee).
- **Default Renewal Amount**: A default amount for renewal invoices, which can be overridden on individual contracts.

## Navigation and Usability

### REQ-11: Contract List View

Users shall have access to a list view of all support contracts, with filtering and sorting capabilities on key fields including:

- Contract number
- Customer name / number
- Service level
- Status
- Start date / End date
- Auto-renew (yes/no)

### REQ-12: Contract Detail View

A detailed contract view (card page) shall display all contract information including customer details, service level, dates, status, auto-renew setting, renewal amount, linked contacts, and notes. Users shall be able to edit the contract from this view based on the contract's current status.

### REQ-13: Customer Navigation

From a customer record in Business Central, users should be able to navigate to view all support contracts associated with that customer.

# Business Process Flows

## New Contract Creation

```
1. User navigates to the Support Contracts list.
2. User creates a new contract (system assigns a contract number).
3. User selects the customer.
4. User selects the service level.
5. User enters the start and end dates.
6. User optionally enables Auto-Renew.
7. User optionally sets a contract-specific renewal amount.
8. User adds up to three contract contacts.
9. User adds any notes or description.
10. User activates the contract (status moves from Draft to Active).
```

## Contract Renewal

```
1. A contract with Auto-Renew enabled approaches its end date.
2. User (or scheduled process) initiates the renewal process.
3. System identifies qualifying contracts.
4. System creates a draft sales invoice for each qualifying contract:
   - Customer: from the contract
   - Line item: configured renewal item
   - Amount: contract-specific renewal amount, or default from setup
5. System advances the contract's start and end dates by one year.
6. System records the renewal date on the contract.
7. User reviews the draft invoice, makes any adjustments, and posts it.
8. Invoice is sent to the customer through normal Business Central processes.
```

## Contract Cancellation

```
1. User opens the active contract.
2. User selects action to cancel the contract.
3. System prompts for confirmation.
4. Contract status changes to Cancelled.
5. Auto-Renew is automatically disabled.
6. Contract remains in the system for historical reference.
```

# Recommendations

The following recommendations go beyond the stated requirements and are suggested to enhance the solution's value. Each is optional and can be included or deferred based on Acme Co.'s priorities.

## R-1: Renewal Amount on Contract

**Recommendation**: Store a renewal amount directly on each contract record, in addition to the default amount in setup. This allows different customers or service levels to have different pricing without manual adjustment of every renewal invoice.

**Business Value**: Reduces invoice corrections and supports tiered pricing by service level.

## R-2: Expiring Contracts Report

**Recommendation**: Provide a report or filtered view showing contracts expiring within a configurable number of days (e.g., 30, 60, 90 days). This gives the sales and support team early visibility into upcoming renewals or expirations.

**Business Value**: Proactive renewal management reduces contract lapses and revenue loss.

## R-3: Customer Balance Warning

**Recommendation**: Display a visual indicator on the contract when the linked customer has an overdue balance or is blocked. This does not prevent contract creation but alerts the user to a potential issue.

**Business Value**: Reduces risk of extending support to customers with outstanding payment issues.

## R-4: Contract History / Audit Trail

**Recommendation**: Maintain a log of key contract events such as activation, renewal, cancellation, and status changes. This provides an audit trail for management review.

**Business Value**: Supports internal governance and provides transparency into contract lifecycle.

## R-5: Email Notifications (Future Phase)

**Recommendation**: In a future phase, consider sending automated email notifications to contract contacts when a contract is approaching expiration or has been renewed. This could leverage Business Central's built-in email capabilities.

**Business Value**: Improves customer communication and reduces manual follow-up.

## R-6: Service Level–Based Pricing Defaults

**Recommendation**: Allow default renewal amounts to be configured per service level (e.g., Standard = $X, Expedited = $Y, Full Service = $Z). When a user selects a service level on a new contract, the renewal amount auto-populates.

**Business Value**: Speeds up contract creation and ensures pricing consistency.

## R-7: Bulk Renewal Processing

**Recommendation**: Provide a batch action to process all eligible contract renewals at once, rather than requiring one-by-one processing. Include a confirmation step showing all contracts that will be renewed before invoices are created.

**Business Value**: Significant time savings during renewal periods when many contracts expire simultaneously.

## R-8: External Document Reference

**Recommendation**: Include a field on the contract for an external document number or reference (e.g., the customer's purchase order number). This reference can be carried onto the renewal invoice.

**Business Value**: Simplifies the customer's accounts payable process and reduces invoice disputes.

# Security & Permissions

## REQ-14: Permission-Based Access

Access to support contract functionality shall be controlled through Business Central's standard permission set model. A dedicated permission set shall be provided that grants users the ability to:

- View, create, edit, and delete support contracts
- Initiate the renewal process
- Access the support contract setup

Administrators can assign this permission set to users or user groups as appropriate. Users without the permission set will not have access to support contract pages or actions.

# Reporting

## REQ-15: Contract List Filtering and Export

Users shall be able to filter the contract list by any combination of status, service level, customer, date range, and auto-renew setting. The filtered list shall be exportable to Excel using Business Central's standard export functionality.

## REQ-16: Expiring Contracts View

Users shall be able to quickly identify contracts expiring within a given timeframe using list filters. See also Recommendation R-2 for an enhanced reporting option.

# Assumptions & Constraints

| # | Assumption / Constraint |
|---|------------------------|
| A-1 | Acme Co. uses Dynamics 365 Business Central Online (SaaS). The solution will be deployed as a per-tenant extension. |
| A-2 | Customers and contacts already exist in Business Central. This solution does not create or manage customer or contact master data. |
| A-3 | Contracts are primarily annual, but the system allows flexibility in date ranges. |
| A-4 | Renewal invoicing uses Business Central's standard Sales Invoice functionality. |
| A-5 | The solution will be available in English only for the initial release. |
| A-6 | No integration with external systems is required for the initial release. |
| A-7 | Users will have appropriate Business Central licenses (Essentials or Premium). |

# Acceptance Criteria

| ID | Criteria |
|----|----------|
| AC-1 | A user can create a support contract linked to an existing customer with a selected service level, start date, end date, and auto-renew setting. |
| AC-2 | Up to three contacts from the customer's contact records can be associated with a contract; the system prevents adding more than three. |
| AC-3 | A contract can transition through the defined statuses: Draft → Active → Expired or Cancelled. |
| AC-4 | When the renewal process is run, a draft sales invoice is created for each qualifying auto-renew contract with the correct customer, item, and amount. |
| AC-5 | After renewal invoice creation, the contract's start and end dates advance by one year and the last renewed date is recorded. |
| AC-6 | The contract list can be filtered by status, service level, customer, and date range. |
| AC-7 | Access to support contract functionality is controlled by a dedicated permission set. |
| AC-8 | A unique contract number is assigned to each contract from a configurable number series. |

# Appendix: Requirement Traceability

| Requirement | Source | Priority |
|-------------|--------|----------|
| REQ-1: Contract Creation | Customer Request | Must Have |
| REQ-2: Service Levels | Customer Request | Must Have |
| REQ-3: Customer Linkage | Customer Request | Must Have |
| REQ-4: Contract Contacts | Customer Request | Must Have |
| REQ-5: Contract Dates | Customer Request | Must Have |
| REQ-6: Contract Status | Recommendation | Should Have |
| REQ-7: Contract Number Series | Recommendation | Should Have |
| REQ-8: Auto-Renew Toggle | Customer Request | Must Have |
| REQ-9: Renewal Invoice Creation | Customer Request | Must Have |
| REQ-10: Setup and Configuration | Recommendation | Should Have |
| REQ-11: Contract List View | Recommendation | Should Have |
| REQ-12: Contract Detail View | Recommendation | Should Have |
| REQ-13: Customer Navigation | Recommendation | Nice to Have |
| REQ-14: Permission-Based Access | Recommendation | Should Have |
| REQ-15: List Filtering and Export | Recommendation | Should Have |
| REQ-16: Expiring Contracts View | Recommendation | Nice to Have |
| R-1: Renewal Amount on Contract | Recommendation | Should Have |
| R-2: Expiring Contracts Report | Recommendation | Nice to Have |
| R-3: Customer Balance Warning | Recommendation | Nice to Have |
| R-4: Contract History / Audit Trail | Recommendation | Nice to Have |
| R-5: Email Notifications | Recommendation (Future) | Deferred |
| R-6: Service Level–Based Pricing | Recommendation | Nice to Have |
| R-7: Bulk Renewal Processing | Recommendation | Should Have |
| R-8: External Document Reference | Recommendation | Nice to Have |
