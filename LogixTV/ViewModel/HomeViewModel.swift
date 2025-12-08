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
    @Published var carousels: [String: [CarouselContent]] = [:]
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
                baseURL: .main, path: "carousels/mobile-home?page=1&count=10",
                method: .GET
            ) as CarouselGroupModel
            
            carouselGroups = carouselGroupResponse.data
            
            print("✅ carouselGroupResponse:", carouselDisplayNameList)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadCarouselContents() async {
        
        var startTime = Date()
        print("➡️ startTime: \(startTime)")
        
        for name in carouselNameList {
            let path = "content/\(name)?page=1&count=10"
            print("➡️ Requesting: \(path)")

            do {
                let response = try await NetworkManager.shared.request(
                    baseURL: .main,
                    path: path,
                    method: .GET
                ) as CarouselResponse
                
                if let data = response.data {
                    carousels[name] = data
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        //print("✅ Carousels:", carousels)
        print("➡️ endTime: \(Date().timeIntervalSince(startTime))")
    }
}
