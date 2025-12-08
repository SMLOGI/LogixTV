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
                //.id(url.absoluteString)
                .animation(.none, value: url) // ✅ suppress implicit animation
        } else {
            placeholder
        }
    }
}
