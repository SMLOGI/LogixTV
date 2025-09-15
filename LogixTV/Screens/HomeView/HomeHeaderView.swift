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
                            BannerCarouselView(
                                content: content,
                                viewModel: viewModel,
                                focusedItem: $focusedItem,
                                currentPage: $currentPage
                            )
                            .id(index) // important for scrollTo
                            .frame(width: UIScreen.main.bounds.width - 60) // full-screen card
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
                        /*.onMoveCommand { dir in
                            if dir == .left {
                                // go back to sidebar
                                focusedItem = .menu(0)
                            }
                        }*/
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
            .frame(width: UIScreen.main.bounds.width - 60)
            .background(.blue)
            .focusSection() // optional: marks the whole HStack as a section
            .padding(.bottom, 340)
            .padding(.leading, 60.0)

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
struct BannerCarouselView: View {
    let content: CarouselContent
    let viewModel: CarouselViewModel
    @FocusState.Binding var focusedItem: FocusTarget?
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack(alignment: .leading) {
            BannerImageView(content: content)
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(1.0), Color.black.opacity(0.0)]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            
            BannerDetailView(content: content, focusedItem: $focusedItem)
                .frame(height: 300)
        }
        //.focused($focusedItem, equals: .mainContent)
        //.focusSection()
    }
}

// MARK: - Featured Movie Section
struct BannerDetailView: View {
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
                //RoundedRectButton(title: "WATCH NOW", focusedItem: $focusedItem) {}
                    //.focused($focusedItem, equals: .playButton)

            PlayButton(focusedItem: $focusedItem)
                    /*.onMoveCommand { dir in
                        if dir == .right {
                            focusedItem = .pageDot(0)
                        }
                        if dir == .left {
                            // go back to sidebar
                            focusedItem = .menu(0)
                        }
                    }*/
                 
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, 0)

            Spacer()
        }
        .padding(.leading, 50)
        .background(.clear)
        .focusSection()
    }
}
/*
/// MARK: - Play Button
struct PlayButton: View {
    @FocusState.Binding var focusedItem: FocusTarget?
    var body: some View {
        Button {
            print("play")
        } label: {
            
            HStack(spacing: 10.0) {
                Image(systemName: "play.fill")
                    .foregroundColor(.white)
                Text("PLAY")
                    .font(focusedItem == .playButton ? .caption.bold() : .caption)
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.borderless)
        .padding()
        .frame(width: 160, height: 35)
        .padding()
        .background(Color.appPurple)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: focusedItem == .playButton ? 4 : 0)
        )
        .scaleEffect(focusedItem == .playButton ? 1.05 : 1.0)
        .focused($focusedItem, equals: .playButton)
        .animation(.easeInOut(duration: 0.2), value: focusedItem)
        .onChange(of: focusedItem) { oldValue, newValue in
            print(newValue)
        }
    }
}
 */
struct RoundedRectButton: View {
    let title: String
    @FocusState.Binding var focusedItem: FocusTarget?

    let action: () -> Void
    //@FocusState private var isFocused: Bool
 
    private enum Layout {
        static let textPadding = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        static let borderWidth: CGFloat = 1
        static let focusedBorderWidth: CGFloat = 4
        static let cornerRadius: CGFloat = 25
        static let buttonWidth: CGFloat = 154
        static let buttonHeight: CGFloat = 40
    }
 
    private enum Colors {
        static let unfocusedTextColor = Color(hex: "#A7A7A7")
        static let focusedTextColor = Color.white
        static let backgroundColor = Color.black
        static let focusedBackgroundColor = Color(hex: "#EE1D24")
        static let borderColor = Color(hex: "#575757")
        static let focusedBorderColor = Color.white
    }
 
    var body: some View {
        
        Text(title)
            .font(.custom(focusedItem == .playButton ? "Roboto-Bold" : "Roboto-Regular", size: 18))
            .padding(Layout.textPadding)
            .foregroundColor(focusedItem == .playButton ? Colors.focusedTextColor : Colors.unfocusedTextColor)
            .frame(width: Layout.buttonWidth, height: Layout.buttonHeight)
            .background(focusedItem == .playButton ? Colors.focusedBackgroundColor : Colors.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .stroke(focusedItem == .playButton ? Colors.focusedBorderColor : Colors.borderColor,
                            lineWidth: focusedItem == .playButton ? Layout.focusedBorderWidth : Layout.borderWidth)
            )
            .cornerRadius(Layout.cornerRadius)
            .focusable(true)
            .focused($focusedItem ,equals: .playButton)
            .onTapGesture {
                action()
            }
            .onChange(of: focusedItem) { oldValue, newValue in
                print(newValue,"newValue")
            }
    }
}

struct PlayButton: View {
    @FocusState.Binding var focusedItem: FocusTarget?

    var body: some View {
        HStack(spacing: 10.0) {
            Image(systemName: "play.fill")
            Text("Play")
        }
        .frame(width: 160, height: 35)
        .font(focusedItem == .playButton ? .caption.bold() : .caption)
        .padding()
        .background(focusedItem == .playButton ? Color.appPurple : Color.red)
        .foregroundColor(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: focusedItem == .playButton ? 4 : 0)
        )
        .scaleEffect(focusedItem == .playButton ? 1.05 : 1.0)
        .focusable(true)                  // ✅ enables tvOS focus engine (parallax)
        .focused($focusedItem, equals: .playButton)
        .onChange(of: focusedItem) { oldValue ,newValue in
            debugFocusedItem(newValue)
        }
        .onTapGesture {
            print("Play tapped")          // custom tap action
        }
        .animation(.easeInOut(duration: 0.2), value: focusedItem)
    }
    
    func debugFocusedItem(_ item: FocusTarget?) {
        guard let item = item else {
            print("👉 No item focused")
            return
        }

        switch item {
        case .menu(let index):
            print("👉 Focus on Menu item \(index)")
        case .pageDot(let index):
            print("👉 Focus on PageDot \(index)")
        case .playButton:
            print("👉 Focus on Play Button")
        case .carouselItem(let index):
            print("👉 Focus on Carousel item \(index)")
        case .mainContent:
            print("👉 Focus on Main Content")
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
