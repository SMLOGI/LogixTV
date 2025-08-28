//
//  FocusableCell.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 26/08/25.
//

import Foundation
import SwiftUI
/*
struct FocusableCell: View {
    let item: CarouselItem
    @FocusState.Binding var focusedItem: FocusTarget?
    let onTap: () -> Void
    
    var isFocused: Bool {
        focusedItem == .carouselItem(item.id)
    }
    
    var body: some View {
        VStack {
            Button {
                onTap()
            } label: {
                VStack {
                    Image(systemName: item.imageName)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .padding()
                    
                    Text(item.title)
                        .foregroundColor(isFocused ? .green : .white)
                }
                .frame(width: 120, height: 140)
                .background(isFocused ? Color.gray.opacity(0.4) : Color.clear)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            .focused($focusedItem, equals: .carouselItem(item.id))
        }
        .padding()
    }
}
*/
