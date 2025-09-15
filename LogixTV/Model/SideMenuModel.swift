//
//  SideMenuModel.swift
//  LogixTV
//
//  Created by Subodh  on 14/08/25.
//

import Foundation

// MARK: - Welcome
struct SideMenu: Codable {
    let code: Int
    let data: [Datum]
    let requestID: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case code, data
        case requestID = "request_id"
        case status
    }
}

// MARK: - Datum
struct Datum: Codable {
    let id: Int
    let menuGroupName, menuGroupDisplayName: String
    let menu: [Menu]
    
    enum CodingKeys: String, CodingKey {
        case id
        case menuGroupName = "menu_group_name"
        case menuGroupDisplayName = "menu_group_display_name"
        case menu
    }
}

// MARK: - Menu
struct Menu: Codable, Hashable {
    let id: Int
    let name: String
    let toVersion, fromVersion: Int
    let displayType, navigationType: DisplayTypeClass
    let details: Details
    let subMenu: JSONNull?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)   // uniqueness only by id
    }
    
    static func == (lhs: Menu, rhs: Menu) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Details
struct Details: Codable {
    let name, displayName: String
    let typeID: Int
    let menuType: MenuType
    let key, data, primaryParameter, secondaryParameter: String
    let selectedImageLink, unselectedImageLink, focusImageLink: String
    let ordering: Int
    
    enum CodingKeys: String, CodingKey {
        case name, displayName
        case typeID = "typeId"
        case menuType, key, data, primaryParameter, secondaryParameter, selectedImageLink, unselectedImageLink, focusImageLink, ordering
    }
}

// MARK: - MenuType
struct MenuType: Codable {
    let id: Int
    let name, displayName: String
}

// MARK: - DisplayTypeClass
struct DisplayTypeClass: Codable {
    let name, displayName: String
}


class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public func hash(into hasher: inout Hasher) {
        // No-op
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
