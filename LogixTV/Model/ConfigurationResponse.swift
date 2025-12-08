//
//  ConfigurationResponse.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 08/12/25.
//

import Foundation

// MARK: - Root
struct ConfigurationResponse: Codable {
    let code: Int
    let data: [DeviceConfig]
    let requestID: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case code, data, status
        case requestID = "request_id"
    }
}

// MARK: - Device Config
struct DeviceConfig: Codable {
    let deviceID: Int
    let deviceName: String
    let deviceDisplayName: String
    let configs: Configs

    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case deviceName = "device_name"
        case deviceDisplayName = "device_display_ame"
        case configs
    }
}

// MARK: - Configs
struct Configs: Codable {
    let planToKey: String?
    let adConfig: String?
    let androidMobile: String?
    let noOfCards: CardCounts?
    let theme: String?

    enum CodingKeys: String, CodingKey {
        case planToKey = "Plan-to-key "
        case adConfig
        case androidMobile = "android-mobile"
        case noOfCards = "no_of_cards"
        case theme
    }
}

// MARK: - Card counts
struct CardCounts: Codable {
    let ratio16x9: Double?
    let ratio3x4: Double?

    enum CodingKeys: String, CodingKey {
        case ratio16x9 = "16x9"
        case ratio3x4 = "3x4"
    }
}
