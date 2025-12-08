//
//  ConfigViewModel.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 08/12/25.
//

import Foundation
import SwiftUI

@MainActor
final class ConfigViewModel: ObservableObject {
    @Published var deviceName: String?
    @Published var errorMessage: String?

    func loadConfiguration() async {
        do {
            let carouselGroupResponse = try await NetworkManager.shared.request(
                baseURL: .main, path: "configuration/4",
                method: .GET
            ) as ConfigurationResponse
            
            deviceName = carouselGroupResponse.data.first?.deviceName ?? ""
            
            print("✅ ConfigurationResponse:", carouselGroupResponse)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
