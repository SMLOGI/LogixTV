//
//  CarouselCardView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//
import SwiftUI


struct CarouselCardButtonView: View, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.item.id == rhs.item.id &&
        lhs.focusedItem == rhs.focusedItem
    }

    let item: CarouselContent
    let group: CarouselGroupData?
    @FocusState.Binding var focusedItem: FocusTarget?
    let cardSize: CGSize
    
    @State private var showDetails = false
    @EnvironmentObject var globalNavState: GlobalNavigationState
    var completion: (()->Void)?
    var body: some View {
        Button(action: {
            if item.contentTypeEnum != .collection {
                globalNavState.contentItem = item
                completion?()
            }
        }) {
            VStack(alignment: .leading) {
                if let url = item.bestImageURL {
                    CachedAsyncImage(url: url)
                        .scaledToFill()
                        .clipped()
                } else {
                    Color.gray
                }
            }
            .frame(width: cardSize.width, height: cardSize.height)
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
                    guard globalNavState.lastFocus != newValue else { return }  // <-- IMPORTANT
                    globalNavState.lastFocus = newValue
                    print("****** CarouselCardButtonView focus: \(String(describing: globalNavState.lastFocus))")

                }
            }
        }
    }
}


