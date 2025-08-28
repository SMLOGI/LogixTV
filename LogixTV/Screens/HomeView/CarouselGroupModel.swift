//
//  HomeModel.swift
//  LogixTV
//
//  Created by Subodh  on 28/08/25.
//

// MARK: - Welcome
struct CarouselGroupModel: Codable {
    let status: String
    let code, totalCount: Int
    let data: [CarouselGroupData]
    let requestID: String
    
    enum CodingKeys: String, CodingKey {
        case status, code, totalCount, data
        case requestID = "request_id"
    }
}

// MARK: - Datum
struct CarouselGroupData: Codable {
    let id: Int
    let name, displayName: String
    let fromVersion, toVersion: Int
    let description, action, actionPath: String
    let active, showTrayTitle, showMore: Bool
    let resultCount, order: Int
    let languages: [CarouselType]
    let bgImageID: [BgImageID]
    let carouselType, playlistType: CarouselType
    
    enum CodingKeys: String, CodingKey {
        case id, name, displayName, fromVersion, toVersion, description, action, actionPath, active, showTrayTitle, showMore, resultCount, order, languages
        case bgImageID = "bgImageId"
        case carouselType, playlistType
    }
}

// MARK: - BgImageID
struct BgImageID: Codable {
    let type, profile, imageLink, layoutType: String
}

// MARK: - CarouselType
struct CarouselType: Codable {
    let id: Int
    let name, displayName: String
}
