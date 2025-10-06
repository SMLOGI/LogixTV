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
    @Published var filteredItems: [CarouselContent] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Example dataset
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
            filteredItems = []
        } else {
            Task {
                do {
                    let searchResponse = try await NetworkManager.shared.request(
                        baseURL: .main, path: "allcontent?title=\(text)",
                        method: .GET
                    ) as CarouselResponse
                    
                    filteredItems = searchResponse.data ?? []
                    
                    print("✅ searchResponse:", searchResponse)
                } catch {
                    //errorMessage = error.localizedDescription
                }
            }
        }
    }
}
