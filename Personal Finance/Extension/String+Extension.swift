//
//  String+Extension.swift
//  Personal Finance
//
//  Created by TiniT on 9/7/26.
//

import Foundation

extension String {
    /// Localize a string using your JSON File
    /// If the key is not found return the same key
    /// that prevent replace untagged values
    ///
    /// - returns: localized key or same text
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func toDecimal() -> Decimal {
        Decimal(string: self) ?? 0
    }
}
