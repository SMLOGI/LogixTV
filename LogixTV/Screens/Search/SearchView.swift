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
           // SearchBar(text: $viewModel.searchText)
            
            // Recent searches
           /* if !viewModel.recentSearches.isEmpty {
                Text("Recent Searches")
                    .font(.title3)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.recentSearches, id: \.self) { query in
                            Button(query) {
                                viewModel.searchText = query
                                viewModel.performSearch()
                            }
                            .focusable(true)
                        }
                    }
                }
            }
            */
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: .zero) {
                            ForEach(viewModel.filteredItems, id: \.id) { item in
                                HStack(spacing: 0) {
                                    CarouselCardButtonView(item: item, group: nil, focusedItem: $focusedField)
                                }
                                .padding(20)
                                
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding()
                    }
                }
            }
        }
        .searchable(text: $viewModel.searchText)
    }
}
