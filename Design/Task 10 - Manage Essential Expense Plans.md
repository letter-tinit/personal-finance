# Task 10 - Manage Essential Expense Plans

## Flow

```text
Fixed Plan -> Add -> Plan form -> Save
           -> Tap row -> Edit -> Save or Delete
           -> Swipe row -> Confirm delete
           -> Check unfinished -> Prefilled transaction form -> Save -> Done
```

The feature manages monthly estimates only. Fixed plans remain separate from actual
transactions and do not affect allocation actual, remaining, status, or progress.

## Rules

- plans belong only to Needs or Necessities
- name is required
- amount must be zero or greater
- zero represents an expected expense whose monthly amount is not known yet
- amount type is either fixed or estimated
- total is derived from the current plan collection
- checking a plan prefills a transaction but still requires confirmation
- the confirmed transaction date defaults to the check time
- a completed plan stores the created transaction ID
- deleting the linked transaction resets the plan to unfinished
- changing the actual transaction amount does not change the planned amount
- no persistence in this task
