//
//  BalanceViewModelFactory.swift
//  Personal Finance
//
//  Created by TiniT on 20/7/26.
//

protocol AppViewModelFactory {
    func makeBalanceViewModel() -> BalanceViewModel
    func makeNetWorthViewModel() -> NetWorthViewModel
}
