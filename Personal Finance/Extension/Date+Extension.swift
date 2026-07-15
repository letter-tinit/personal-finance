//
//  Date+Extension.swift
//  Habit
//
//  Created by TiniT on 29/4/26.
//

import Foundation

enum DateFormat {
    case classic // MMM d, yyyy
    case dayNameSymbol // T (Tuesday)
    case dayName // Tu (Tuesday)
    case dayNo // 26 (Number of day only)
    case dayNameWithNo // Tue, 26 (combine of day number and day name)
    case monthAndYear // July 2026
    case custom(String) // Passing date format throught string
    
    var value: String {
        switch self {
        case .classic:
            "MMM d, yyyy"
        case .dayNameSymbol:
            "EEEEE"
        case .dayName:
            "EEEEEE"
        case .dayNo:
            "d"
        case .dayNameWithNo:
            "EEE, d"
        case .monthAndYear:
            "MMMM yyyy"
        case .custom(let value):
            value
        }
    }
}

extension Date {
    func isToday() -> Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    func toString(withFormat dateFormat: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat.value
        return formatter.string(from: self)
    }
    
    func isEqual(with targetDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: targetDate)
    }

    func isFutureDay() -> Bool {
        Calendar.current.startOfDay(for: self) > Calendar.current.startOfDay(for: Date())
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? startOfDay(for: date)
    }

    func nextMonth(after date: Date) -> Date {
        self.date(
            byAdding: .month,
            value: 1,
            to: startOfMonth(for: date)
        ) ?? startOfMonth(for: date)
    }
}
