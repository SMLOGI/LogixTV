//
//  MoviesResponse.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 14/05/25.
//

import Foundation

struct MoviesResponse: Codable {
    let code: Int
    let data: [Movie]
}

struct Movie: Codable, Identifiable {
    let id: Int
    let contentId: String
    let title: String
    let tagline: String?
    let description: String
    let duration: Int?
    let isFree: Bool
    let publishedDate: String
    let contentType: NamedType
    let subContentType: NamedType?
    let language: NamedType
    let images: [ImageData]
    let releaseStatus: ReleaseStatus
    let genre: [Genre]
    let productionHouse: [ProductionHouse]
    let displayTags: [DisplayTag]
    
    var imageThumbnail : String? {
        if let image = images.first(where: { $0.type == "portrait_3x4"}) {
            return image.imageLink
        }
        return nil
    }
    
    struct NamedType: Codable {
        let id: Int?
        let name: String
        let displayName: String
    }

    struct ImageData: Codable {
        let id: Int?
        let type: String?
        let profile: String?
        let imageLink: String?
        let layoutType: String?
    }

    
    struct ReleaseStatus: Codable {
        let id: Int?
        let releasedDate: String?
        let ottReleasedDate: String?
        let tvReleasedDate: String?
        let budget: String?
        let revenue: String?
        
        enum CodingKeys: String, CodingKey {
            case id, releasedDate, ottReleasedDate = "OttReleasedDate", tvReleasedDate = "tvReleasedDate", budget, revenue
        }
    }
    
    struct Genre: Codable {
        let id: Int
        let name: String
        let displayName: String
        let image: ImageData?
    }

    struct ProductionHouse: Codable {
        let id: Int?
        let name: String
        let displayName: String
        let description: String?
        let image: ImageData?
    }

    struct DisplayTag: Codable {
        let id: Int?
        let name: String
        let displayName: String
        let carouselType: String?
        let image: ImageData?
    }
}
