//
//  CarouselCardView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//
import SwiftUI


// MARK: - Single Card
struct BannerImageView: View {
    let content: CarouselContent
    
    var body: some View {
        VStack {
            if let imageUrl = content.imageURL(for: .landscape16x9) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        Color.gray
                    case .success(let image):
                        image
                        .resizable()
                        .scaledToFill()   // ✅ fills the screen
                        .ignoresSafeArea() // ✅ edge-to-edge
                    case .failure(_):
                        Color.red
                    @unknown default:
                        Color.gray
                    }
                }
            } else {
                Color.gray
            }

        }
    }
}
