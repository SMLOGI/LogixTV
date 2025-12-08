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
    @Published var logo: Menu?
    @Published var menuList: [Menu] = []
    @Published var errorMessage: String?
    
    
    func loadMenu(_ deviceName: String) async {
        do {
            let sideMenu = try await NetworkManager.shared.request(
                baseURL: .main, path: "menu/\(deviceName)",
                method: .GET
            ) as SideMenu
            self.logo = sideMenu.data.first?.menu.filter({ $0.name == "logo" }).first
            self.menuList = sideMenu.data.first?.menu.filter({ $0.displayType.name == "bottom-menu" }).sorted(by: { $0.details.ordering < $1.details.ordering }) ?? []
            print("self.menuList =\(self.menuList)")
            
            } catch {
            errorMessage = error.localizedDescription
        }
    }
}
