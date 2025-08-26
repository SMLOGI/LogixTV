//
//  SideMenuViewModel.swift
//  LogixTV
//
//  Created by Subodh  on 14/08/25.
//

import Foundation
import SwiftUI

@MainActor
final class SideMenuViewModel: ObservableObject {
    @Published var menuGroups: [Datum] = []
    @Published var errorMessage: String?
    
    
    func loadMenu() async {
        do {
            let sideMenu = try await NetworkManager.shared.request(
                baseURL: .main, path: "menu/tv",
                method: .GET
            ) as SideMenu
            
            menuGroups = sideMenu.data
            
            print("✅ Side menu loaded:", menuGroups)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
