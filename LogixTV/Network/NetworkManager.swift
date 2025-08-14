//
//  NetworkManager.swift
//  LogixTV
//
//  Created by Subodh  on 14/08/25.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

enum BaseURL: String {
    case main = "http://LogixCmsProd-2099249738.ap-south-1.elb.amazonaws.com:7040/user/v1/"
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(
        baseURL: BaseURL,
        path: String,
        method: HTTPMethod,
        body: Data? = nil,
        headers: [String: String]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        
        guard let url = URL(string: baseURL.rawValue + path) else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        print("Request URL: \(url.absoluteString)")
        print("HTTP Method: \(method.rawValue)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "InvalidResponse", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        print("Status Code: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body: \(responseString)")
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error with status code \(httpResponse.statusCode)"])
        }
        
        //        do {
        //            if let jsonString = String(data: data, encoding: .utf8) {
        //                print("📜 Raw JSON:\n\(jsonString)")
        //            }
        //            return try decoder.decode(T.self, from: data)
        //        } catch {
        //            throw NSError(domain: "DecodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Decoding failed: \(error.localizedDescription)"])
        //        }
        do {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📜 Raw JSON:\n\(jsonString)")
            }
            return try decoder.decode(T.self, from: data)
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Missing key: \(key.stringValue) in JSON: \(context.debugDescription)")
            print("CodingPath:", context.codingPath)
            throw DecodingError.keyNotFound(key, context)
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Type mismatch for type: \(type) in JSON: \(context.debugDescription)")
            print("CodingPath:", context.codingPath)
            throw DecodingError.typeMismatch(type, context)
        } catch let DecodingError.valueNotFound(value, context) {
            print("❌ Value not found for type: \(value) in JSON: \(context.debugDescription)")
            print("CodingPath:", context.codingPath)
            throw DecodingError.valueNotFound(value, context)
        } catch let DecodingError.dataCorrupted(context) {
            print("❌ Data corrupted:", context.debugDescription)
            throw DecodingError.dataCorrupted(context)
        } catch {
            print("❌ Decoding error:", error.localizedDescription)
            throw error
        }
    }
}
