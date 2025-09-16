//
//  CachedAsyncImage.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 16/09/25.
//

import Foundation
import SwiftUI

struct CachedAsyncImage: View {
    @State private var uiImage: UIImage?
    let url: URL?
    private var placeholder = Color.gray.opacity(0.2)
    private var contentMode: ContentMode = .fill
    
    // ✅ Make contentMode configurable
    init(
        url: URL?,
        contentMode: ContentMode = .fill,       // default .fill
        placeholder: Color = Color.gray.opacity(0.2)
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }
    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
                    .onAppear(perform: loadImage)
            }
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        if let cached = ImageCache.shared.image(forKey: url.absoluteString) {
            self.uiImage = cached
            return
        }
        
        // Fetch from network
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            ImageCache.shared.setImage(image, forKey: url.absoluteString)
            DispatchQueue.main.async {
                self.uiImage = image
            }
        }.resume()
    }
}
