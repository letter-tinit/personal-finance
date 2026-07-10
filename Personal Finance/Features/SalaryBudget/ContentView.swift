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
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(income.formattedVND)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Divider()
                        
                        HStack {
                            Text("budget.method".localized)
                                .font(.default)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text(budgetMethod.localizationKey.localized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
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
                .borderedBackground()
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
            .background(Color.Common.background)
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
        VStack(alignment: .leading) {
            HStack {
                Text(bucket.kind.localizationKey.localized)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(((bucket.ratio.doubleValue * 100).cleanString) + "%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Text(bucket.amount.formattedVND)
                .font(.title)
                .fontWeight(.bold)
            
            ZStack {
                Color.gray
                    .opacity(0.2)
                
                bucket.kind.progressColor
                    .scaleEffect(x: bucket.ratio.doubleValue, y: 1, anchor: .leading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 8)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .borderedBackground()
    }
}

#Preview {
    ContentView()
}
