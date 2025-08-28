//
//  HomeViewModel.swift
//  LogixTV
//
//  Created by Subodh  on 28/08/25.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var carouselGroups: [CarouselGroupData] = []
    @Published var errorMessage: String?
    
    var carouselNameList: [String] {
        carouselGroups.map { $0.name }
    }
    
    var carouselDisplayNameList: [String] {
        carouselGroups.map { $0.displayName }
    }
    
    func loadCarouselGroup() async {
        do {
            let carouselGroupResponse = try await NetworkManager.shared.request(
                baseURL: .main, path: "carousels/mobile-listen?page=1&count=10",
                method: .GET
            ) as CarouselGroupModel
            
            carouselGroups = carouselGroupResponse.data
            
            print("✅ carouselGroupResponse:", carouselDisplayNameList)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
