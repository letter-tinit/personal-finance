# Task 9 - Edit And Delete Transactions

## Interaction

```text
Tap transaction -> Edit form -> Save
                              -> Delete -> Confirm
```

The edit screen reuses `TransactionFormView` with prefilled `TransactionFormState`.
Changing allocation also changes transaction semantics automatically: savings-like
allocations produce contributions; other allocations produce expenses.

## Domain operations

- `Budget.updateTransaction(...)` validates the new allocation and amount, then
  replaces the transaction while preserving its identity.
- `Budget.deleteTransaction(id:)` removes only a transaction owned by the budget.
- Overview values remain derived from the current transaction collection, so old
  and new allocation totals update without separate synchronization state.

Persistence remains out of scope.
