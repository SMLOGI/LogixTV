//
//  SettingsOptionButton.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 20/05/25.
//

import SwiftUI

struct SettingsOptionButton: View {
    let systemImage: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .padding(.trailing, 10)
        }
    }
}
