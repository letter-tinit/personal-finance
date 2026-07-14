# Task 8 - Create Transaction

## Flow

```text
Budget detail -> Add -> Transaction form -> Validate -> Save -> Updated overview
```

## Form

- Description
- Allocation
- Amount
- Date
- Payment method
- Optional note

The selected allocation determines transaction semantics automatically:

- savings-like allocation -> contribution
- other allocation -> expense

The form does not expose transaction type because it is a domain rule, not a user choice.

## Data boundary

```text
TransactionFormState
    -> validatedInput()
ValidatedTransactionInput
    -> Budget.addTransaction(...)
BudgetTransaction
```

`TransactionFormState` owns UI-oriented values such as `amountText`. Only validated,
typed values cross into the `Budget` domain model.

## Validation

- description is required
- allocation is required
- amount must be a positive number

Task 8 keeps changes in memory only. Persistence remains out of scope.
