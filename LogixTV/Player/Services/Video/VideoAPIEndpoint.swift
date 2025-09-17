//
//  VideoAPIEndpoint.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 15/05/25.
//

import Foundation

enum VideoAPIEndpoint: APIEndpoint {
    case videoURL(videoID: String)

    var path: String {
        switch self {
        case .videoURL(let id):
            return "/user/v1/videourl/\(id)"
        }
    }

    var method: String { "GET" }
    var headers: [String : String]? { nil }
    var body: Data? { nil }
    var queryItems: [URLQueryItem]? { nil }
}
