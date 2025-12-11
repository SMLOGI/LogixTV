//
//  CarouselResponse.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//

import Foundation

// MARK: - Root
struct CarouselResponse: Codable {
    let status: String?
    let code: Int?
    let totalCount: Int?
    let data: [CarouselContent]?
    let requestID: String?

    enum CodingKeys: String, CodingKey {
        case status, code, totalCount, data
        case requestID = "request_id"
    }
}
enum CarouselImageType: String {
    case landscape16x9 = "landscape_16x9"
    case portrait3x4   = "portrait_3x4"
    case square1x1     = "square_1x1"
}

enum ContentTypeString: String {
    case video = "video"
    case vod   = "vod"
    case collection = "collection"
    case live = "live"
}
// MARK: - Content
struct CarouselContent: Codable {
    let id: Int
    let contentId: String?
    let title: String?
    let tagline: String?
    let description: String?
    let overView: String?
    let duration: Int?
    let runtime: String?
    let state: Int?
    let isFree: Bool?
    let contentType: CarouselContentType?
    let subContentType: CarouselContentType?
    let publishedType: CarouselPublishedType?
    let publishedDate: String?
    let language: CarouselLanguage?
    let parentalRating: CarouselParentalRating?
    let rating: [CarouselRating]?
    let images: [CarouselImage]?
    let releaseStatus: CarouselReleaseStatus?
    let genre: [CarouselGenre]?
    let productionHouse: [CarouselProductionHouse]?
    let studio: CarouselStudio?
    let displayTags: [CarouselDisplayTag]?
    let deeplink: CarouselDeeplink?
    let partners: [CarouselPartner]?
    let customParameters: [CarouselCustomParameter]?
    let seriesMeta: CarouselSeriesMeta?
    let preview: [CarouselPreview]?
    let cast: [CarouselCast]?
    let altmeta: [CarouselAltmeta]?
    let keyword: [CarouselKeyword]?
    let country: CarouselCountry?
    let video: [CarouselContentVideo]?

    enum CodingKeys: String, CodingKey {
        case id, contentId, title, tagline, description
        case overView = "OverView"
        case duration, runtime, state, isFree, contentType
        case subContentType = "SubContentType"
        case publishedType, publishedDate, language, parentalRating, rating, images, releaseStatus, genre, productionHouse, studio, displayTags, deeplink, partners, customParameters, seriesMeta, preview, cast, altmeta, keyword, country, video
    }
}


extension CarouselContent {
    
    /// Preferred landscape 16:9 image
    var landscape16x9URL: URL? {
        imageURL(for: .landscape16x9)
    }
    
    /// Generic accessor by type
    func imageURL(for type: CarouselImageType) -> URL? {
        images?
            .first(where: { $0.type! == type.rawValue })
            .flatMap { img in
                guard let link = img.imageLink else { return nil }
                return URL(string: link)
            }
    }
    
    /// Returns best available image with fallback order
    var bestImageURL: URL? {
        if let url = imageURL(for: .landscape16x9) {
            return url
        } else if let url = imageURL(for: .portrait3x4) {
            return url
        } else if let url = imageURL(for: .square1x1) {
            return url
        }
        return nil
    }
    
    var isLiveContent: Bool {
        contentTypeEnum == .live
    }
    
    var contentTypeEnum: ContentTypeString {
        if let typeName = contentType?.name {
            return ContentTypeString(rawValue: typeName) ?? .video
        }
        return .video
    }
}

// MARK: - ContentType
struct CarouselContentType: Codable {
    let id: Int?
    let name: String?
    let displayName: String?
}

// MARK: - PublishedType
struct CarouselPublishedType: Codable {
    let name: String?
    let createdAt: String?
}

// MARK: - Language
struct CarouselLanguage: Codable {
    let id: Int?
    let name: String?
    let displayName: String?
}

// MARK: - ParentalRating
struct CarouselParentalRating: Codable {
    let id: Int?
    let name: String?
    let shortName: String?
    let tagline: String?
    let description: String?
    let warningTitle: String?
    let isKid: Bool?
    let image: CarouselImage?
}

// MARK: - Rating
struct CarouselRating: Codable {
    let providerName: String?
    let providerDisplayName: String?
    let rating: Int?
    let ratingLimit: Int?
    let type: String?
}

// MARK: - Image
struct CarouselImage: Codable {
    let type: String?
    let profile: String?
    let imageLink: String?
    let layoutType: String?
}

// MARK: - ReleaseStatus
struct CarouselReleaseStatus: Codable {
    let id: Int?
    let releasedDate: String?
    let ottReleasedDate: String?
    let tvReleasedDate: String?
    let budget: String?
    let revenue: String?

    enum CodingKeys: String, CodingKey {
        case id, releasedDate, budget, revenue
        case ottReleasedDate = "OttReleasedDate"
        case tvReleasedDate
    }
}

// MARK: - Genre
struct CarouselGenre: Codable {
    let name: String?
    let displayName: String?
    let image: CarouselImage?
}

// MARK: - ProductionHouse
struct CarouselProductionHouse: Codable {
    let id: Int?
    let name: String?
    let displayName: String?
    let description: String?
    let image: CarouselImage?
}

// MARK: - Studio
struct CarouselStudio: Codable {
    let name: String?
    let displayName: String?
}

// MARK: - DisplayTag
struct CarouselDisplayTag: Codable {
    let name: String?
    let displayName: String?
    let carouselType: String?
    let image: CarouselImage?
}

// MARK: - Deeplink
struct CarouselDeeplink: Codable {
    let name: String?
    let link: String?
}

// MARK: - Partner
struct CarouselPartner: Codable {
    let id: Int?
    let name: String?
    let displayName: String?
    let description: String?
    let image: CarouselImage?
}

// MARK: - CustomParameter
struct CarouselCustomParameter: Codable {
    let name: String?
    let key: String?
    let value: String?
}

// MARK: - SeriesMeta
struct CarouselSeriesMeta: Codable {
    let index: Int?
    let popularity: Int?
    let episodeNumber: Int?
    let parentContentId: String?
    let subParentContentId: String?
}

struct CarouselContentVideo: Codable {
    let contentUrl: String?
}

// MARK: - Preview
struct CarouselPreview: Codable {
    let type: String?
    let mimetype: String?
    let carouselType: String?
    let image: CarouselImage?
    let videoURL: CarouselVideoURL?

    enum CodingKeys: String, CodingKey {
        case type, mimetype, carouselType, image
        case videoURL = "videoURL"
    }
}

// MARK: - VideoURL
struct CarouselVideoURL: Codable {
    let type: String?
    let profile: String?
    let drmEnabled: Bool?
    let licenceUrl: String?
    let contentUrl: String?
    let protocolType: String?
    let encryptionType: String?
    let qualityBitrate: Int?

    enum CodingKeys: String, CodingKey {
        case type, profile
        case drmEnabled = "drm_enabled"
        case licenceUrl, contentUrl
        case protocolType = "protocol"
        case encryptionType, qualityBitrate
    }
}

// MARK: - Cast
struct CarouselCast: Codable {
    let name: String?
    let displayName: String?
    let gender: String?
    let ordering: Int?
    let popularity: Int?
    let role: CarouselRole?
    let image: CarouselImage?
}

// MARK: - Role
struct CarouselRole: Codable {
    let name: String?
    let displayName: String?
    let image: CarouselImage?
}

// MARK: - Altmeta
struct CarouselAltmeta: Codable {
    let title: String?
    let tagline: String?
    let description: String?
    let overview: String?
    let language: String?
}

// MARK: - Keyword
struct CarouselKeyword: Codable {
    let id: Int?
    let name: String?
    let displayName: String?
}

// MARK: - Country
struct CarouselCountry: Codable {
    let displayName: String?
    let name: String?
    let imageLink: String?
    let shortName: String?
    let phoneCode: String?
    let active: Int?
    let timezone: String?
}
