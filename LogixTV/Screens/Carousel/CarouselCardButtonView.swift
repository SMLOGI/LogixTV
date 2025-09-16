//
//  CarouselCardView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//
import SwiftUI


struct CarouselCardButtonView: View {
    let item: CarouselContent
    @FocusState.Binding var focusedItem: FocusTarget?
    var body: some View {
        Button(action: {
            // handle card tap
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
        }
        .focused($focusedItem, equals: .carouselItem(item.id))
        .buttonStyle(.card)
    }
}

