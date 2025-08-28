//
//  CarouselTVView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 28/08/25.
//

import SwiftUI

// MARK: - TV Carousel View
struct CarouselTVView: View {
    let contents: [CarouselContent]
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {

    }
}

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

// MARK: - Preview
struct CarouselTVView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselTVView(contents: sampleContents)
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Sample Data
let sampleContents: [CarouselContent] = [
    CarouselContent(
        id: 1,
        contentId: "AXHTO24vGO",
        title: "Mission Impossible",
        tagline: "The Final Reckoning",
        description: "Action spy film...",
        overView: "",
        duration: 137,
        runtime: "",
        state: 0,
        isFree: false,
        contentType: nil,
        subContentType: nil,
        publishedType: nil,
        publishedDate: "31-07-2025",
        language: nil,
        parentalRating: nil,
        rating: nil,
        images: [CarouselImage(type: "", profile: "", imageLink: "https://logix-cms-content.s3.ap-south-1.amazonaws.com/content/actual/AXHTO24vGO/image/28319b3a9875a1a3477a.jpg", layoutType: "")],
        releaseStatus: nil,
        genre: nil,
        productionHouse: nil,
        studio: nil,
        displayTags: nil,
        deeplink: nil,
        partners: nil,
        customParameters: nil,
        seriesMeta: nil,
        preview: nil,
        cast: nil,
        altmeta: nil,
        keyword: nil,
        country: nil
    )
]
