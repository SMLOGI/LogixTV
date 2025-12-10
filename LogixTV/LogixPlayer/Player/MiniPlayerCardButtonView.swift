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
        lhs.focusedControl == rhs.focusedControl
    }

    let item: MiniPlayerContent
    @FocusState.Binding var focusedControl: LivePlayerControlsView.ControlFocus?
    @State private var showDetails = false
    @EnvironmentObject var globalNavState: GlobalNavigationState
    var completion: (()->Void)?
    var body: some View {
        HStack {
            Button(action: {
                globalNavState.miniPlayerItem = item
                completion?()
            }) {
                VStack {
                    if let imageUrl = URL(string: item.imageUrl) {
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
                        .stroke(.white, lineWidth: focusedControl == .miniPlayer(item.id) ? 10 : 0)
                )
            }
            .focused($focusedControl, equals: .miniPlayer(item.id))
            .buttonStyle(.card)
        }
    }
}
