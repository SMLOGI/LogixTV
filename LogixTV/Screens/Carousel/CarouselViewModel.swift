//
//  CarouselViewModel.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//

import Foundation
import SwiftUI

@MainActor
final class CarouselViewModel: ObservableObject {
    @Published var contentList: [CarouselContent] = []
    @Published var errorMessage: String?
    
    
    func loadCarousel() async {
        do {
            let corosalResponse = try await NetworkManager.shared.request(
                baseURL: .main, path: "content/hollywood_movies?page=1&count=10",
                method: .GET
            ) as CarouselResponse
            
            contentList = corosalResponse.data ?? []
            print("✅ CarouselResponse:", corosalResponse.totalCount)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
