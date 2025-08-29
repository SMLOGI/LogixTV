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
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 0) {
                        ForEach(Array(viewModel.contentList.enumerated()), id: \.1.id) { (index, content) in
                            CarouselItemView(
                                content: content,
                                viewModel: viewModel,
                                focusedItem: $focusedItem,
                                currentPage: $currentPage
                            )
                            .id(index) // important for scrollTo
                            .frame(width: UIScreen.main.bounds.width ) // full-screen card
                        }
                    }
                    .padding(.horizontal, 30)
                    .focusSection()
                }
                .onChange(of: currentPage) { newPage in
                    // Scroll to the selected page when currentPage changes (tap or focus)
                    withAnimation {
                        proxy.scrollTo(newPage, anchor: .center)
                    }
                }
            }
            
            // MARK: Pager Dots
             HStack(spacing: 12) {
                ForEach(viewModel.contentList.indices, id: \.self) { index in
                    Circle()
                        .fill(focusedItem == .pageDot(index) ? Color.white : (index == currentPage ? Color.white : Color.gray.opacity(0.5)))
                        .frame(width: 20, height: 20)
                        .focusable(true)
                        .focused($focusedItem, equals: .pageDot(index)) // each dot individually focusable
                        .onChange(of: focusedItem) { newFocus in
                            // Scroll carousel when a dot receives focus
                            if newFocus == .pageDot(index) {
                                withAnimation {
                                    currentPage = index
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                currentPage = index
                            }
                        }
                }
            }
            .focusSection() // optional: marks the whole HStack as a section

            .padding(.bottom, 200)
            
            // MARK: Error Message
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            
            FeaturedMovieView(content: content, focusedItem: $focusedItem)
        }
        .focusSection()
    }
}

// MARK: - Featured Movie Section
struct FeaturedMovieView: View {
    let content: CarouselContent
    @FocusState.Binding var focusedItem: FocusTarget?

    var body: some View {
        HStack {
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
                
                PlayButton(focusedItem: $focusedItem)
                    .onMoveCommand { dir in
                        if dir == .right {
                            focusedItem = .pageDot(0)
                        }
                    }
                
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, 60)

            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(1.0), Color.black.opacity(0.0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .focusSection()
    }
}

// MARK: - Play Button
struct PlayButton: View {
    @FocusState.Binding var focusedItem: FocusTarget?
    var body: some View {
        Button(action: {
            print("Play tapped")
        }) {
            HStack(spacing: 10.0) {
                Image(systemName: "play.fill")
                Text("Play")
            }
            .frame(width: 160, height: 35)
            .font(focusedItem == .playButton ? .caption.bold() : .caption)
            .padding()
            .background(Color.appPurple)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .buttonStyle(.plain) // tvOS focus bounce
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: focusedItem == .playButton ? 4 : 0)
        )
        .scaleEffect(focusedItem == .playButton ? 1.05 : 1.0)
        .focusable(true)
        .focused($focusedItem, equals: .playButton)
        .animation(.easeInOut(duration: 0.2), value: focusedItem)
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
extension Color {
    static let appPurple = Color(hex: "#590DE5")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            red: Double(r)/255,
            green: Double(g)/255,
            blue: Double(b)/255
        )
    }
}
