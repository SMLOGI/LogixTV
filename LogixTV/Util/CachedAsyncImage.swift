//
//  CachedAsyncImage.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 16/09/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    private var placeholder: Color
    private var contentMode: ContentMode
    private var showsIndicator: Bool

    // MARK: - Init
    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        placeholder: Color = Color.gray.opacity(0.2),
        showsIndicator: Bool = true // optional activity indicator
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
        self.showsIndicator = showsIndicator
    }

    // MARK: - Body
    var body: some View {
        if let url = url {
            WebImage(url: url)
                .resizable() // Must include for SwiftUI layout control
                .aspectRatio(contentMode: contentMode)
                .clipped()
        } else {
            placeholder
        }
    }
}


/*
struct CachedAsyncImage: View {
    @State private var uiImage: UIImage?
    let url: URL?
    private var placeholder: Color
    private var contentMode: ContentMode

    // MARK: - Init
    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        placeholder: Color = Color.gray.opacity(0.2)
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    // MARK: - Body
    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
                    .onAppear(perform: loadImage)
            }
        }
    }

    // MARK: - Load Image
    private func loadImage() {
        guard let url = url else { return }

        // Return cached image if exists
        if let cached = ImageCache.shared.image(forKey: url.absoluteString) {
            self.uiImage = cached
            return
        }

        // Fetch from network
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            // Decode image in background
            DispatchQueue.global(qos: .userInitiated).async {
                if let image = UIImage(data: data) {
                    // Cache the image
                    ImageCache.shared.setImage(image, forKey: url.absoluteString)

                    // Update UI on main thread
                    DispatchQueue.main.async {
                        self.uiImage = image
                    }
                }
            }
        }.resume()
    }
}
*/
