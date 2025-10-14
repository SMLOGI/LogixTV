//
//  CarouselCardView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//
import SwiftUI


struct CarouselCardButtonView: View {
    let item: CarouselContent
    let group: CarouselGroupData?
    @FocusState.Binding var focusedItem: FocusTarget?
    @State private var showDetails = false
    @EnvironmentObject var globalNavState: GlobalNavigationState
    var completion: (()->Void)?
    var body: some View {
        Button(action: {
                globalNavState.contentItem = item
                completion?()
           // }
        }) {
            VStack(alignment: .leading) {
                if let imageUrl = item.imageURL(for: .landscape16x9) {
                    CachedAsyncImage(url: imageUrl)
                        .aspectRatio(16/9, contentMode: .fit)
                } else {
                    Rectangle()
                        .fill(Color.gray)
                }
            }
            .frame(width: 267, height: 150)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white, lineWidth: focusedItem == .carouselItem(group?.id ?? 9999, item.id) ? 10 : 0)
            )
        }
        .focused($focusedItem, equals: .carouselItem(group?.id ?? 9999, item.id))
        .buttonStyle(.card)
        .onCompatibleChange(of: focusedItem) { oldValue, newValue in
            if newValue != nil && oldValue != newValue {
                if case .carouselItem = newValue, case .carouselItem = oldValue {
                    globalNavState.lastFocus = newValue
                }
            }
        }
    }
}


