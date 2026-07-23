//
//  CommonEmptyView.swift
//  Personal Finance
//
//  Created by TiniT on 23/7/26.
//

import SwiftUI

struct CommonEmptyView: View {
    let title: String
    let description: String
    let imageName: String
    
    init(
        title: String = "common.empty.title".localized,
        description: String = "common.empty.description".localized,
        imageName: String = "list.bullet.rectangle"
    ) {
        self.title = title
        self.description = description
        self.imageName = imageName
    }
    
    var body: some View {
        ContentUnavailableView {
            Label(
                title,
                systemImage: imageName
            )
        } description: {
            Text(description)
        }
    }
}

#Preview {
    CommonEmptyView()
}
