//
//  CaptionToggleButton.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 20/05/25.
//

import SwiftUI

struct CaptionToggleButton: View {
    @Binding var captionsEnabled: Bool
    var toggleAction: ((Bool) -> Void)?

    var body: some View {
        Button(action: {
            captionsEnabled.toggle()
            toggleAction?(captionsEnabled)
        }) {
            Label(captionsEnabled ? "On" : "Off",
                  systemImage: captionsEnabled ? "captions.bubble.fill" : "captions.bubble")
                .foregroundColor(captionsEnabled ? .green : .gray)
                .padding(10)
                .background(
                    Capsule()
                        .strokeBorder(captionsEnabled ? Color.green : Color.gray, lineWidth: 1.5)
                )
        }
    }
}


#Preview {
    CaptionToggleButton(captionsEnabled: .constant(true), toggleAction: nil)
}
