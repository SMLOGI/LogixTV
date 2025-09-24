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
    @ObservedObject var homeViewModel: HomeViewModel
    @EnvironmentObject var globalNavState: GlobalNavigationState

    // Number of rows in horizontal grid
    let rows: [GridItem] = [
        GridItem(.flexible(minimum: 500, maximum: .infinity), spacing: 0)
    ]
    
    // Track the current focused card for pager dots
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            ScrollViewReader { proxy in
                    TabView(selection: $currentPage) {
                        ForEach(Array(viewModel.contentList.enumerated()), id: \.1.id) { (index, content) in
                            HeroBannerCarouselView(
                                content: content,
                                viewModel: viewModel,
                                homeViewModel: homeViewModel,
                                focusedItem: $focusedItem,
                                currentPage: $currentPage
                            )
                            .id(index) // important for scrollTo
                            .frame(width: UIScreen.main.bounds.width - 60) // full-screen card
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .onChange(of: currentPage) { newPage in
                    // Scroll to the selected page when currentPage changes (tap or focus)
                    
                }
            
            // MARK: Pager Dots
            HStack(spacing: 12) {
                ForEach(viewModel.contentList.indices, id: \.self) { index in
                    let isSelected = currentPage == index
                    let isFocused = focusedItem == .playButton
                    let size = isFocused && isSelected ? 25.0 : 20.0
                    Circle()
                        .fill(isSelected ? Color.white : Color.gray)
                        .opacity(isFocused ? 1 : 0.8)
                        .frame(width: size,height: size)
                        .onTapGesture {
                            withAnimation {
                                currentPage = index
                            }
                        }
                }
            }
            .frame(width: UIScreen.main.bounds.width - 60)
            .background(.clear)
           // .focusable(true)
           // .focused($focusedItem, equals: .pageDot) // each dot individually focusable
           // .focusSection() // optional: marks the whole HStack as a section
           /* .onMoveCommand { dir in
                withAnimation {
                    if dir == .left {
                        // go back to sidebar
                        if currentPage == 0 {
                            focusedItem = .playButton
                        } else {
                            currentPage = (currentPage - 1)
                            focusedItem = .playButton
                        }
                    } else if dir == .down {
                        if case .carouselItem = globalNavState.lastFocus {
                            print("*** globalNavState.lastFocus Id =\(String(describing: globalNavState.lastFocus))")
                            if let firstGroup = homeViewModel.carouselGroups.first {
                                print("*** first section = \(firstGroup.name) and Id =\(firstGroup.id)")
                                focusedItem = globalNavState.lastFocus
                        }
                        } else if let firstGroup = homeViewModel.carouselGroups.first, let firstItem = homeViewModel.carousels[firstGroup.name]?.first {
                            focusedItem = .carouselItem(firstGroup.id, firstItem.id)
                        }
                    } else if dir == .right {
                        if currentPage < viewModel.contentList.count - 1 {
                            currentPage = currentPage + 1
                            focusedItem = .playButton
                        } else {
                            if let firstGroup = homeViewModel.carouselGroups.first, let firstItem = homeViewModel.carousels[firstGroup.name]?.first {
                                focusedItem = .carouselItem(firstGroup.id, firstItem.id)
                            }
                        }
                    }
                }
            } */
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
        .focusSection()
        .task {
            await viewModel.loadCarousel()
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
