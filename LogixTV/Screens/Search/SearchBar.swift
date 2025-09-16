//
//  SearchBar.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 16/09/25.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool   // tvOS focus state

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search...", text: $text)
                .focused($isFocused)
                .textFieldStyle(.plain)
                .font(.title2)
                .padding(10)
                .background(Color(.systemGray))
                .cornerRadius(10)
        }
        .padding()
        .onAppear {
            // Optionally focus automatically when screen appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isFocused = true
            }
        }
    }
}
