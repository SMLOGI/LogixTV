//
//  SearchViewModel.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 16/09/25.
//

import Foundation
import SwiftUI
import Combine

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var items: [String] = []      // Your full dataset
    @Published var filteredItems: [String] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Example dataset
        items = ["Apple", "Banana", "Mango", "Orange", "Pineapple", "Grapes"]

        // Observe searchText and filter items dynamically
        $searchText
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.filterItems(with: text)
            }
            .store(in: &cancellables)
    }

    private func filterItems(with text: String) {
        if text.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { $0.localizedCaseInsensitiveContains(text) }
        }
    }
}
