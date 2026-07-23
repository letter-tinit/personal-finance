//
//  NetWorthListScreen.swift
//  Personal Finance
//

import SwiftUI
import SwiftData

/// Entry point for yearly Net Worth data. Each row owns one year's plan and
/// monthly snapshots; `NetWorthScreen` renders the selected year's months.
struct NetWorthListScreen: View {
    @Environment(NetWorthRouter.self) private var router
    
    @State private var title: String = "networth.list.title".localized
    @State private var viewModel: NetWorthViewModel
    @State private var selectedYear = Calendar.current.component(
        .year,
        from: Date()
    )
    @State private var hasLoadedData = false
    @State private var isCreateNewYearPresented: Bool = false
    @State private var isDeleteConfirmationPresented: Bool = false
    @State private var netWorthYearToDelete: NetWorthYear? {
        didSet {
            isDeleteConfirmationPresented = true
        }
    }
    
    @Query(
        sort: \NetWorthYear.year,
        order: .reverse
    )
    private var netWorthYears: [NetWorthYear]
    
    init(_ viewModel: NetWorthViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        BaseScreen($title) {
            List {
                ForEach(netWorthYears.sorted { $0.year > $1.year }) { data in
                    Button {
                        router.push(.yearNetworth(data))
                    } label: {
                        NetWorthYearRow(data: data)
                    }
                    .swipeActions {
                        Button {
                            netWorthYearToDelete = data
                        } label: {
                            VStack {
                                Text("common.delete".localized)
                                    .secondarySubHeadline()
                                
                                Image(module: "trash")
                                    .tint(.red)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isCreateNewYearPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .toast(message: viewModel.toastMessage, position: .top)
        .deleteConfirmationDialog(isPresented: $isDeleteConfirmationPresented) {
            viewModel.removeNetWorth(netWorthYearToDelete)
        }
        .onChange(of: netWorthYears) {
            viewModel.save()
        }
        .sheet(isPresented: $isCreateNewYearPresented) {
            YearPickerSheet(futureYears: 0) { year in
                viewModel.createNetWorthYear(year)
            }
            .presentationDetents([.medium])
        }
    }
}

private struct NetWorthYearRow: View {
    let data: NetWorthYear
    
    var body: some View {
        HStack {
            Text(String(data.year))
                .font(.headline)
            
            Spacer()
            
            Text(
                String(
                    format: "networth.year.monthCount".localized,
                    locale: .current,
                    data.snapshots.count
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NetWorthListScreen(PreviewHelper.makeNetWorthViewModel())
        .modelContainer(
            PreviewContainer.shared.container
        )
}
