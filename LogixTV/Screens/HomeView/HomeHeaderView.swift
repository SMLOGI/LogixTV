//
//  HomeHeaderView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 26/08/25.
//

import Foundation
import SwiftUI

// MARK: - HomeHeaderView
struct HomeHeaderView: View {
    @StateObject private var viewModel = CarouselViewModel()
    @FocusState.Binding var focusedItem: FocusTarget?
    
    // Number of rows in horizontal grid
    let rows: [GridItem] = [
        GridItem(.flexible(minimum: 500, maximum: .infinity), spacing: 0)
    ]
    
    // Track the current focused card for pager dots
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: Horizontal Grid Carousel
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 30) {
                    ForEach(viewModel.contentList, id: \.self.id) { content in
                        CarouselItemView(
                            content: content,
                            viewModel: viewModel,
                            focusedItem: $focusedItem,
                            currentPage: $currentPage
                        )
                        .background(Color.yellow)
                    }
                }
                .padding(.horizontal, 60)
            }
            
            // MARK: Pager Dots
            HStack(spacing: 8) {
                ForEach(viewModel.contentList.indices, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.white : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.leading, 60)
            
            // MARK: Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .task {
            await viewModel.loadCarousel()
        }
    }
}

// MARK: - Extracted Subview
struct CarouselItemView: View {
    let content: CarouselContent
    let viewModel: CarouselViewModel
    @FocusState.Binding var focusedItem: FocusTarget?
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            CarouselCardView(content: content)
                .ignoresSafeArea()
            
            FeaturedMovieView(content: content)
                .modifier(FocusWrapper(
                    contentID: content.id,
                    focusedItem: $focusedItem,
                    currentPage: $currentPage,
                    viewModel: viewModel
                ))
        }
    }
}

// MARK: - Featured Movie Section
struct FeaturedMovieView: View {
    let content: CarouselContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            
            PlayButton()
        }
        .frame(maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(1.0), Color.black.opacity(0.8)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .padding(.leading, 70)
    }
}

// MARK: - Play Button
struct PlayButton: View {
    var body: some View {
        Button(action: {
            print("Play tapped")
        }) {
            HStack {
                Image(systemName: "play.fill")
                Text("Play")
            }
            .font(.title2)
            .padding()
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .buttonStyle(.card) // tvOS focus bounce
    }
}

// MARK: - Focus Wrapper Modifier
struct FocusWrapper: ViewModifier {
    let contentID: Int
    @FocusState.Binding var focusedItem: FocusTarget?
    @Binding var currentPage: Int
    let viewModel: CarouselViewModel
    
    func body(content: Content) -> some View {
        content
            .focusable(true)
            .focused($focusedItem, equals: .carouselItem(contentID))
            .onChange(of: focusedItem) { newFocus in
                guard case let .carouselItem(id) = newFocus else { return }
                if let idx = viewModel.contentList.firstIndex(where: { $0.id == id }) {
                    currentPage = idx
                }
            }
    }
}
