//
//  CarouselCardView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//
import SwiftUI


struct CarouselCardButtonView: View {
    let item: CarouselContent
    let group: CarouselGroupData
    @FocusState.Binding var focusedItem: FocusTarget?
    @State private var showPlayer = false
    @State private var showDetails = false
    @EnvironmentObject var globalNavState: GlobalNavigationState
    
    var body: some View {
        Button(action: {
//            if item.subContentType?.name!.lowercased() == "movie" {
//                showPlayer = true
//            } else if item.subContentType?.name!.lowercased() == "episode" {
//                showDetails = true
//            } else {
                showPlayer = true
                globalNavState.contentItem = item
                globalNavState.showPlayer = true
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
            .frame(height: 150)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white, lineWidth: focusedItem == .carouselItem(group.id, item.id) ? 10 : 0)
            )
        }
        .focused($focusedItem, equals: .carouselItem(group.id, item.id))
        .buttonStyle(.card)
    }
}


