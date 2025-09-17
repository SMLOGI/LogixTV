//
//  MovieAPIEndPoint.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 14/05/25.
//

import Foundation

enum MovieAPIEndPoint: APIEndpoint {
    case classicMovies(count: Int, page: Int)

    var path: String {
        return "/user/v1/content/classic_movies"
    }

    var method: String {
        return "GET"
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var body: Data? {
        return nil
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .classicMovies(let count, let page):
            return [
                URLQueryItem(name: "count", value: "\(count)"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        }
    }
}

protocol APIEndpoint {
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var queryItems: [URLQueryItem]? { get }
}

extension APIEndpoint {
    var urlRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: APIConfig.baseURL + path) else { return nil }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        return request
    }
}
struct APIConfig {
    static var baseURL: String {
        // You can use environment flags here
        return "http://LogixCms-1616970263.ap-south-1.elb.amazonaws.com:7040"
    }
}
