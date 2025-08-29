//
//  CarouselCardView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//
import SwiftUI


// MARK: - Single Card
struct CarouselCardView: View {
    let content: CarouselContent
    
    var body: some View {
        VStack {
            if let imageUrl = content.images?.first?.imageLink, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
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
