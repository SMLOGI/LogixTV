//
//  HTMLTextFetcher.swift
//  News18AppleTV
//
//  Created by Joshua Sebastin  on 23/01/25.
//

import Foundation

struct HTMLTextFetcher {
    let url: URL

    func fetchHTML(completion: @escaping (Result<String, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let htmlString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "HTMLTextFetcher", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data was received from the server."])))
                return
            }

            let styledHTML = createStyledHTML(with: htmlString)
            convertToPlainString(html: styledHTML, completion: completion)
        }.resume()
    }

    private func createStyledHTML(with htmlContent: String) -> String {
        """
        <html>
        <head>
        <meta charset="UTF-8">
        <style>
            body {
                font-family: -apple-system;
                line-height: 1.8;
                color: black;
                margin: 0;
                padding: 0;
            }
        </style>
        </head>
        <body>\(htmlContent)</body>
        </html>
        """
    }

    private func convertToPlainString(html: String, completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let attributedString = try NSAttributedString(
                    data: html.data(using: .utf8)!,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
                )
                DispatchQueue.main.async {
                    completion(.success(attributedString.string))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
