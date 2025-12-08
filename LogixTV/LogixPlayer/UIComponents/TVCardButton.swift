//
//  TVCardButton.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 05/12/25.
//

import SwiftUI

struct TVCardButton: View {
    let title: String
    let selectedtitle: String
    @FocusState.Binding var focusedSection: LivePlayerControlsView.ControlFocus?
    let action: () -> Void
    @EnvironmentObject var globalNavState: GlobalNavigationState

    var body: some View {
        Button(action: action) {
            Text(globalNavState.isShowMutiplayerView ? selectedtitle : title)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 7)
                .background(focusedSection == .goLiveButton ? Color.white.opacity(0.2) : Color.gray.opacity(0.3))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(focusedSection == .goLiveButton ? .white : .clear, lineWidth: 2)
                )
        }
        .buttonStyle(.borderless)
        .focused($focusedSection, equals: .goLiveButton)
    }
}
