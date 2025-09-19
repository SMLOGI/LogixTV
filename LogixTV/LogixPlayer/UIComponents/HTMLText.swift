//
//  HTMLText.swift
//  News18AppleTV
//
//  Created by Mohan R on 25/10/24.
//
import SwiftUI

struct HTMLText: View {
    // MARK: - Properties
    let url: URL
    var onFocusChangeRequest: (() -> Void)?
    
    @State private var attributedText: String?
    @State private var errorMessage: String?
    @State private var currentScrollPosition: CGFloat = 0
    @State private var scrollingContentOffset: CGFloat = 100
    @State  var isAtBottom: Bool
    
    // MARK: - Body
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack {
                    contentView
                    bottomMarkerView
                }
                .frame(maxWidth: .infinity)
                .background(Color.clear)
            }
            .coordinateSpace(name: "scroll")
            .focusable()
            .onMoveCommand(perform: handleMoveCommand(proxy: scrollViewProxy))
            .background(Color(hex: "#121212").edgesIgnoringSafeArea(.all))
            .onAppear {
                fetchHTMLContent(from: url)
            }
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        if let attributedText = attributedText {
            Text(attributedText)
                .foregroundColor(.white)
                .padding()
                .id("content")
        } else if let errorMessage = errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
        } else {
            loadingView
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spinner(size: .regular)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            Text("Loading...")
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Bottom Marker View
    private var bottomMarkerView: some View {
        GeometryReader { geometry in
            Color.clear
                .onChange(of: geometry.frame(in: .global).maxY) { markerMaxYGlobal in
                    let screenHeight = UIScreen.main.bounds.height
                    isAtBottom = markerMaxYGlobal <= screenHeight + 10
                }
        }
        .frame(height: 1)
    }
    
    // MARK: - Handle Move Command
    private func handleMoveCommand(proxy: ScrollViewProxy) -> (MoveCommandDirection) -> Void {
        return { direction in
            if direction == .down {
                scrollBy(offset: scrollingContentOffset, proxy: proxy)
            } else if direction == .up {
                if isAtBottom {
                    isAtBottom = false
                }
                scrollBy(offset: -scrollingContentOffset, proxy: proxy)
            }
        }
    }
    
    // MARK: - Scrolling Logic
    private func scrollBy(offset: CGFloat, proxy: ScrollViewProxy) {
        currentScrollPosition += offset
        if !isAtBottom {
            proxy.scrollTo("content", anchor: UnitPoint(x: 0.5, y: max(0, currentScrollPosition / UIScreen.main.bounds.height)))
        } else {
            onFocusChangeRequest?()
        }
    }
    
    // MARK: - Fetch HTML Content
    private func fetchHTMLContent(from url: URL) {
        HTMLTextFetcher(url: url).fetchHTML { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let plainText):
                    self.attributedText = plainText
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
