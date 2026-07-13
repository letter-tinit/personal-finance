//
//  BudgetListScreen.swift
//  Personal Finance
//
//  Created by TiniT on 13/7/26.
//

import SwiftUI

struct BudgetListScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("A")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    BudgetScreen(details: .mock)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BudgetListScreen()
    }
}
