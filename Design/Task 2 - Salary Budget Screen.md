# Task 2 - Salary Budget Screen Design

## Purpose

This screen displays the result of the budget calculation model from Task 1.

For this task, the screen is static:

```text
Salary: 16,000,000
Method: 50/30/20
Buckets: Needs, Wants, Savings
```

The goal is to prove that SwiftUI can call `BudgetMethod.fiftyThirtyTwenty.calculate(...)` and show the returned buckets.

## Scope

Build only one screen:

- title
- salary summary
- selected method
- bucket list

Do not build:

- salary input
- expense input
- navigation
- database
- persistence
- ViewModel
- charts
- funds
- accounts

## Layout

```text
Salary Budget
50/30/20 method

[Monthly Salary]
16,000,000 VND

Budget Buckets

[Needs]
50%
8,000,000 VND

[Wants]
30%
4,800,000 VND

[Savings]
20%
3,200,000 VND
```

## Visual Direction

The screen should feel calm, practical, and easy to scan.

Use:

- white or near-white background
- dark primary text
- muted secondary text
- simple bordered sections
- 8px corner radius
- no decorative gradients
- no complex charts

Suggested colors:

```text
Background: #F6F7F4
Surface:    #FFFFFF
Text:       #1B211D
Muted:      #647069
Border:     #DDE3DD
Accent:     #0F7F68
Needs:      #9B6819
Wants:      #286B8F
Savings:    #0F7F68
```

## SwiftUI Structure

Recommended structure:

```text
ContentView
└── ScrollView
    └── VStack
        ├── Header
        ├── SalarySummary
        └── BucketList
            ├── BucketRow
            ├── BucketRow
            └── BucketRow
```

For Task 2, it is acceptable to keep helper views inside `ContentView.swift`.

Do not create a ViewModel yet.

## Data Rule

The UI must use the model:

```swift
let income: Decimal = 16_000_000
let buckets = BudgetMethod.fiftyThirtyTwenty.calculate(income)
```

The UI should not manually hardcode:

```swift
Needs = 8_000_000
Wants = 4_800_000
Savings = 3_200_000
```

## Display Rule

Money formatting can be simple in this task.

Acceptable:

```text
16000000
8000000
```

Better:

```text
16,000,000
8,000,000
```

Do not spend too much time on perfect currency formatting yet. Formatting can become a later shared helper.

## Pass Criteria

- Screen title is visible.
- Salary is visible.
- Method name is visible.
- Needs, Wants, and Savings are visible.
- Bucket amounts come from `BudgetMethod`.
- No salary input yet.
- No expense input yet.
- No persistence.
- Code remains readable.

