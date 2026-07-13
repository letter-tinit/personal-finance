//
//  ContentView.swift
//  Personal Finance
//
//  Created by TiniT on 9/7/26.
//

import SwiftUI

struct BudgetScreen: View {
    let details: BudgetDetails

    private var budget: Budget {
        details.budget
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ZStack {
                    VStack(alignment: .leading) {
                        Text("monthly.salary".localized)
                            .secondarySubHeadline()
                        
                        Text(budget.income.formattedVND)
                            .customTitle()
                            .foregroundStyle(.green)
                        
                        HStack {
                            Text("budget.method".localized)
                                .customHeadline()
                            
                            Spacer()
                            
                            Text(budget.method.localizationKey.localized)
                                .customSubHeadline()
                                .foregroundStyle(.black.opacity(0.6))
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
                    HStack {
                        Text("budget.buckets.title".localized)
                            .customSubTitle()
                        
                        Spacer()
                        
                        Text(String(format: "budget.buckets.count".localized, details.allocations.count))
                            .customSubText()
                    }
                    
                    ForEach(details.allocations) { allocation in
                        BudgetAllocationView(allocation: allocation)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(budget.name)
        .navigationBarTitleDisplayMode(.large)
        .background(Color.Common.background)
    }
    
}

struct BudgetAllocationView: View {
    let allocation: BudgetAllocation

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(allocation.kind.localizationKey.localized)
                    .customHeadline()
                
                Spacer()
                
                Text(((allocation.ratio.doubleValue * 100).cleanString) + "%")
                    .customSubHeadline()
            }
            
            Text(allocation.targetAmount.formattedVND)
                .customTitle()
            
            GeometryReader { geomrtry in
                ZStack(alignment: .leading) {
                    Color.gray
                        .opacity(0.2)
                    
                    allocation.kind.progressColor
                        .clipShape(.capsule)
                        .frame(width: geomrtry.size.width * allocation.ratio.doubleValue)
                }
            }
            .frame(height: 10)
            .clipShape(.capsule)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .borderedBackground()
    }
}

#Preview {
    BudgetScreen(details: .mock)
        .fontDesign(.rounded)
}
