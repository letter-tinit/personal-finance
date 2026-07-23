//
//  YearMonthGroup.swift
//  Personal Finance
//
//  Created by TiniT on 23/7/26.
//

import Foundation

struct YearMonthKey: Hashable {
    let year: Int
    let month: Int
}


struct YearMonthGroup<Model>: Identifiable {
    let id = UUID()
    
    let year: Int
    let month: Int
    let items: [Model]
    
    var title: String {
        let date = Calendar.current.date(
            from: DateComponents(
                year: year,
                month: month
            )
        )
        
        return date?
            .formatted(
                .dateTime
                .month(.wide)
                .year()
            ) ?? "\(month)/\(year)"
    }
}
