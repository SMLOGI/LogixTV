//
//  SearchView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 16/09/25.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @FocusState.Binding var focusedField: FocusTarget?

    var body: some View {
        VStack {
            SearchBar(text: $viewModel.searchText)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.filteredItems, id: \.self) { item in
                        Text(item)
                            .font(focusedField == .searchItem(item) ? .title2 : .body) // 🔑 choose font based on focus
                            .padding()
                            .background(
                                focusedField == .searchItem(item)
                                ? Color.blue.opacity(0.6) // focused background
                                : Color.gray.opacity(0.3) // normal background
                            )
                            .cornerRadius(8)
                            .scaleEffect(focusedField == .searchItem(item) ? 1.1 : 1.0) // 🔑 subtle zoom on focus
                            .animation(.easeInOut(duration: 0.2), value: focusedField)
                            .focusable(true)
                            .focused($focusedField, equals: .searchItem(item))
                    }
                }
                .padding()
            }
        }
    }
}
