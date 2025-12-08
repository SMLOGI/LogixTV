//
//  MiniPlayerCardButtonView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 05/12/25.
//

import SwiftUI

struct MiniPlayerCardButtonView: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item.id == rhs.item.id &&
        lhs.focusedItem == rhs.focusedItem
    }

    let item: CarouselContent
    @FocusState.Binding var focusedItem: FocusTarget?
    @State private var showDetails = false
    @EnvironmentObject var globalNavState: GlobalNavigationState
    var completion: (()->Void)?
    var body: some View {
        HStack {
            Button(action: {
                globalNavState.contentItem = item
                completion?()
            }) {
                VStack {
                    if let imageUrl = item.imageURL(for: .landscape16x9) {
                        CachedAsyncImage(url: imageUrl)
                            .aspectRatio(16/9, contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                    }
                }
                .frame(width: 356, height: 200)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white, lineWidth: focusedItem == .carouselItem(9999, item.id) ? 10 : 0)
                )
            }
            .focused($focusedItem, equals: .carouselItem(9999, item.id))
            .buttonStyle(.card)
        }
        .padding(.leading, 70)
    }
}
