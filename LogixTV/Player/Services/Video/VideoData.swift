//
//  VideoData.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 15/05/25.
//

import Foundation

struct VideoAPIResponse: Decodable {
    let code: Int
    let data: [VideoData]
    let requestID: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case code, data, status
        case requestID = "request_id"
    }
}

struct VideoData: Decodable {
    let type: String
    let profile: String
    let drmEnabled: Bool
    let licenceUrl: String
    let contentUrl: String
    let `protocol`: String
    let encryptionType: String
    let adInfo: AdInfo?
    let qualityGroup: QualityGroup?

    enum CodingKeys: String, CodingKey {
        case type, profile, licenceUrl, contentUrl, `protocol`, adInfo, encryptionType, qualityGroup
        case drmEnabled = "drm_enabled"
    }
}

struct AdInfo: Decodable {
    let adUrl: String
    let provider: String
    let cuePoints: String
}

struct QualityGroup: Decodable {
    let name: String
    let displayName: String
}
