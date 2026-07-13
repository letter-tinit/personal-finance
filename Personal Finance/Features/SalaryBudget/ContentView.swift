//
//  ContentView.swift
//  Personal Finance
//
//  Created by TiniT on 9/7/26.
//

import SwiftUI

struct ContentView: View {
    @State private var salaryText: String = ""
    @FocusState private var isSalaryFocused: Bool
    
    private var income: Decimal {
        salaryText.toDecimal()
    }
    
    @State private var budgetMethod: BudgetMethod = .fiftyThirtyTwenty
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack {
                    ZStack {
                        VStack(alignment: .leading) {
                            Text("monthly.salary".localized)
                                .secondarySubHeadline()
                            
                            TextField("salary.input.placeholder".localized, text: $salaryText)
                                .customLargeTitle()
                                .keyboardType(.numberPad)
                                .focused($isSalaryFocused)
                            
                            Divider()
                            
                            HStack {
                                Text("budget.method".localized)
                                    .customHeadline()
                                
                                Spacer()
                                
                                Text(budgetMethod.localizationKey.localized)
                                    .customSubHeadline()
                                    .foregroundStyle(.black.opacity(0.6))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .foregroundStyle(Color.lightGreen)
                                    )
                            }
                            
                            Picker("", selection: $budgetMethod) {
                                ForEach(BudgetMethod.allCases, id: \.self) { method in
                                    Text(method.localizationKey.localized)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.top)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .borderedBackground()
                    .padding()
                    
                    VStack {
                        let buckets = budgetMethod.generateBucketByIncome(income)
                        
                        HStack {
                            Text("budget.buckets.title".localized)
                                .customSubTitle()
                            
                            Spacer()
                            
                            Text(String(format: "budget.buckets.count".localized, buckets.count))
                                .customSubText()
                        }
                        
                        ForEach(buckets, id: \.self) { bucket in
                            BudgetBucketView(bucket: bucket)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("salary.budget".localized)
            .navigationBarTitleDisplayMode(.large)
            .background(Color.Common.background)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    
                    Button("keyboard.done".localized) {
                        isSalaryFocused = false
                    }
                }
            }
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
                    .customHeadline()
                
                Spacer()
                
                Text(((bucket.ratio.doubleValue * 100).cleanString) + "%")
                    .customSubHeadline()
            }
            
            Text(bucket.amount.formattedVND)
                .customTitle()
            
            GeometryReader { geomrtry in
                ZStack(alignment: .leading) {
                    Color.gray
                        .opacity(0.2)
                    
                    bucket.kind.progressColor
                        .clipShape(.capsule)
                        .frame(width: geomrtry.size.width * bucket.ratio.doubleValue)
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
    ContentView()
        .fontDesign(.rounded)
}
