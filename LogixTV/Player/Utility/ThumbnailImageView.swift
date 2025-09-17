//
//  ThumbnailImageView.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 15/05/25.
//

import SwiftUI

struct ThumbnailImageView: View {
    let urlString: String?
    let width: CGFloat
    let height: CGFloat

    var imageURL: URL? {
        guard let urlString = urlString,
              !urlString.trimmingCharacters(in: .whitespaces).isEmpty,
              let url = URL(string: urlString)
        else {
            return nil
        }
        return url
    }

    var body: some View {
        if let url = imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: width, height: height)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width, height: height)
                        .clipped()
                case .failure:
                    defaultImage
                @unknown default:
                    defaultImage
                }
            }
        } else {
            defaultImage
        }
    }

    private var defaultImage: some View {
        Image(systemName: "photo")
            .resizable()
            .foregroundColor(.gray)
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
    }
}
