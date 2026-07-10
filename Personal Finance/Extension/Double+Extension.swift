//
//  Double+Extension.swift
//  Personal Finance
//
//  Created by TiniT on 10/7/26.
//

import Foundation

extension Double {
    var cleanString: String {
        formatted(
            .number
                .precision(.fractionLength(0...10))
        )
    }
}
