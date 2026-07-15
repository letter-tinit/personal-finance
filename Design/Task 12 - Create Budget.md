# Task 12 - Create Budget

## Status

Draft. This note is created before implementation planning.

## Current Context

The app already has a Budget List, a readable Budget Detail screen, editable
transactions, and editable essential expense plans. The next Create Budget flow
must create a new in-memory `Budget` that can use those existing screens. It
must not add persistence in this task.

The older [[Task 7 - Create and Activate Budget]] note describes the original
single-screen draft/active idea. It is historical context only; this task needs
to fit the current list-and-detail flow.

## Intended User Flow

```text
Budget List -> Add -> Create Budget form -> Validate -> Create -> Budget Detail
```

The creation form should collect only the values needed to form a valid Budget:

- budget month
- monthly income
- budgeting method
- generated allocation preview

Transactions and Essential Expense Plans start empty. They are added from the
existing detail flow after the budget exists.

## Decisions Needed Before Planning

1. Should a budget be identified by the first day of its month, such as
   `2026-08-01`, or by a user-editable display name as well?
2. What should happen when the user creates a second budget for the same month:
   block it, allow it, or ask the user to replace the current draft?
3. After successful creation, should the app open the new Budget Detail
   immediately or return to Budget List first?
4. Should the existing July mock remain as demo data alongside new in-memory
   budgets during this task?

## Guardrails

- no persistence, database, iCloud sync, or monthly rollover
- no transaction or Fixed Plan setup inside the creation form
- `BudgetMethod` remains pure calculation logic
- generated allocations must match the selected method and income
- invalid or zero income cannot create a Budget
- all new visible text requires English and Vietnamese localization

## Completion Signal

A new valid budget appears in the in-memory Budget List and opens correctly in
the existing detail flow, with empty transactions and Fixed Plans.
