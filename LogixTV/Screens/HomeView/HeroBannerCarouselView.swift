//
//  HeroBannerCarouselView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 15/09/25.
//

import Foundation
import SwiftUI

// MARK: - Extracted Subview
struct HeroBannerCarouselView: View {
    let content: CarouselContent
    let viewModel: CarouselViewModel
    var homeViewModel: HomeViewModel

    @FocusState.Binding var focusedItem: FocusTarget?
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            //BannerImageView(content: content)
            if let imageUrl = content.imageURL(for: .landscape16x9) {
                CachedAsyncImage(url: imageUrl)
                    .ignoresSafeArea()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(1.0), Color.black.opacity(0.0)]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.0)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }  else {
                Rectangle()
                    .fill(Color.gray)
                    .ignoresSafeArea()
            }
            BannerDetailView(content: content, focusedItem: $focusedItem, viewModel: viewModel, homeViewModel: homeViewModel, currentPage: $currentPage)
                .frame(height: 400)
                .padding(.bottom, 200)
        }
        //.focused($focusedItem, equals: .mainContent)
        //.focusSection()
    }
}

// MARK: - Featured Movie Section
struct BannerDetailView: View {
    let content: CarouselContent
    @FocusState.Binding var focusedItem: FocusTarget?
    let viewModel: CarouselViewModel
    var homeViewModel: HomeViewModel
    @Binding var currentPage: Int
    @EnvironmentObject var globalNavState: GlobalNavigationState

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                Text(content.title ?? "")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                if let description = content.description {
                    Text(description)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: 600, alignment: .leading)
                }

                PlayButton(content: content)
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, 0)

            Spacer()
        }
        .padding(.leading, 140)
        .background(.clear)
        .focusSection()
    }
}

/// MARK: - Play Button
struct PlayButton: View {
    let content: CarouselContent
    @EnvironmentObject var globalNavState: GlobalNavigationState

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.subheadline)
                Text("PLAY")
                    .font(.caption)
            }
            .padding(10)
        }
        .frame(width: 120, height: 40)
        .background(Color.appPurple)
        .cornerRadius(12)
    }
}
