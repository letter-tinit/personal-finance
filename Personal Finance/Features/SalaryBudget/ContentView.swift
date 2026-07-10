//
//  ContentView.swift
//  Personal Finance
//
//  Created by TiniT on 9/7/26.
//

import SwiftUI

struct ContentView: View {
    private let income: Decimal = 16_000_000
    private let budgetMethod: BudgetMethod = .fiftyThirtyTwenty
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    VStack(alignment: .leading) {
                        Text("monthly.salary".localized)
                        
                        Text(verbatim: "\(income)")
                        
                        HStack {
                            Text("budget.method".localized)
                            
                            Spacer()
                            
                            Text(budgetMethod.localizationKey.localized)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .foregroundStyle(Color.lightGreen)
                                )
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .background (
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray, lineWidth: 1)
                )
                .padding()
                
                VStack {
                    let buckets = budgetMethod.calculate(income)
                    ForEach(buckets, id: \.self) { bucket in
                        BudgetBucketView(bucket: bucket)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("salary.budget".localized)
            .navigationBarTitleDisplayMode(.large)
        }
        .ignoresSafeArea(.all)
    }
    
    func convertToDecimal(_ text: String) -> Decimal {
        Decimal(string: text) ?? 0
    }
}

struct BudgetBucketView: View {
    let bucket: BudgetBucket
    var body: some View {
        VStack {
            HStack {
                Text(bucket.kind.localizationKey.localized)
                
                Spacer()
                
                Text(verbatim: "\(bucket.ratio * 100) %")
            }
            
            Text(verbatim: "\(bucket.amount)")
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background (
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray, lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
