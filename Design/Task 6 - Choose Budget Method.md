# Task 6 - Choose Budget Method Design

## Purpose

This task adds one UI decision: the user can choose which budgeting method drives the bucket calculation.

The screen should still feel like the same Salary Budget screen. Do not redesign the whole app.

## Scope

Build only:

- salary input
- budget method selector
- bucket list that changes based on selected method

Do not build:

- expense input
- database
- persistence
- account
- fund
- custom method editor
- Settings screen

## Recommended UI

Use a segmented control for method selection because there are only two methods right now.

```text
Salary Budget

[Monthly salary]
16,000,000

[Budget Method]
[ 50/30/20 | 6 Jars ]

Budget Buckets

[Needs]
50%
8,000,000

[Wants]
30%
4,800,000

[Savings]
20%
3,200,000
```

When the user selects `6 Jars`, the same salary input should produce six bucket rows:

```text
Necessities
Financial Freedom
Education
Long-term Savings
Play
Give
```

## Interaction

Default state:

- selected method: `50/30/20`
- salary input can be empty or user-entered
- buckets are calculated from current salary input

When switching method:

- keep current salary input
- recalculate buckets immediately
- update method label and bucket list
- do not reset salary

## Visual Direction

Keep the existing visual style:

- background: `#F6F7F4`
- card/surface: white or clear with border
- border: `#DDE3DD`
- primary text: dark
- secondary text: muted gray
- segmented control: native SwiftUI segmented picker
- bucket progress colors: from `BudgetBucketKind+Style`

Do not add a modal, sheet, or full-screen method picker yet.

## SwiftUI Direction

Recommended state:

```swift
@State private var selectedMethod: BudgetMethod = .fiftyThirtyTwenty
```

Recommended picker shape:

```swift
Picker("budget.method".localized, selection: $selectedMethod) {
    ForEach(BudgetMethod.allCases) { method in
        Text(method.localizationKey.localized)
            .tag(method)
    }
}
.pickerStyle(.segmented)
```

This likely requires:

```swift
enum BudgetMethod: CaseIterable, Identifiable {
    var id: Self { self }
}
```

Keep this in the model only if it is generic identity/list support. Do not put UI color, font, or layout in `BudgetMethod`.

## Data Rule

Use selected method:

```swift
let buckets = selectedMethod.calculate(income)
```

Do not manually switch bucket rows inside the view.

## Pass Criteria

- `50/30/20` selected shows 3 buckets.
- `6 Jars` selected shows 6 buckets.
- Bucket amounts use current salary input.
- Salary does not reset when switching method.
- `BudgetMethod.calculate(...)` remains pure calculation logic.
- No persistence or database is added.
