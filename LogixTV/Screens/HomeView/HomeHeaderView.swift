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
    @State private var focusTransitioning = false
    @State private var lastItemFocused = false
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
                            ZStack{
                                HeroBannerCarouselView(
                                    content: content,
                                    viewModel: viewModel,
                                    homeViewModel: homeViewModel,
                                    focusedItem: $focusedItem,
                                    currentPage: $globalNavState.bannerIndex
                                )
                               // Text("\(currentPage)")
                            }
                            .id(index) // important for scrollTo
                            .frame(width: UIScreen.main.bounds.width - 60) // full-screen card
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }

            
            // MARK: Pager Dots
            HStack(spacing: 12) {
                ForEach(viewModel.contentList.indices, id: \.self) { index in
                    let isSelected = focusedItem == .pageDot(index)
                    let size = isSelected ? 25.0 : 20.0
                    Button {
                        globalNavState.bannerIndex = index
                        currentPage = index
                        globalNavState.contentItem = viewModel.contentList[index]
                        globalNavState.activeScreen = .player
                    } label: {
                        Circle()
                            .fill(isSelected ? Color.white : Color.gray)
                            .frame(width: size, height: size)
                    }
                    .buttonStyle(.borderless) // removes default rectangle highlight
                    .focused($focusedItem, equals: .pageDot(index)) // each dot individually focusable
                    .onMoveCommand { direction in
                        let total = viewModel.contentList.count
                        print("onMoveCommand direction=\(direction) currentPage=\(currentPage)")
                        
                        switch direction {
                        case .right:
                            if currentPage == total {
                                // wrap to first
                                // currentPage = 0
                                // globalNavState.bannerIndex = 0
                                // focusedItem = .pageDot(0)
                            }
                        default:
                            break
                        }
                        
                        withAnimation {
                            globalNavState.bannerIndex = currentPage
                            focusedItem = .pageDot(currentPage)
                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width - 60)
            .background(.clear)
            .focusSection()
            .onCompatibleChange(of: focusedItem) { oldValue, newValue in
                print("HomeHeaderView onCompatibleChange newValue=\(String(describing: newValue))")
                
                if newValue != nil && oldValue != newValue {
                    if case let .pageDot(index) = newValue {
                        print("index=\(index)")
                        print("currentPage=\(currentPage)")
                        //if index < currentPage {
                        //focusedItem = .menu(0)
                        //} else {
                        withAnimation {
                            globalNavState.bannerIndex = index
                            currentPage = index
                        }
                    }
                    if case .pageDot = oldValue,
                       case .carouselItem = newValue {
                        moveToMovieCollection()
                    }
                }
            }
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
    func moveToMovieCollection() {
        focusTransitioning = true

        Task { @MainActor in
            // short pause lets tvOS finish current focus release
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s

            if case .carouselItem = globalNavState.lastFocus,
               let firstGroup = homeViewModel.carouselGroups.first {
                focusedItem = globalNavState.lastFocus
            } else if let firstGroup = homeViewModel.carouselGroups.first,
                      let firstItem = homeViewModel.carousels[firstGroup.name]?.first {
                focusedItem = .carouselItem(firstGroup.id, firstItem.id)
            }

            // release the focus lock after another brief delay
            try? await Task.sleep(nanoseconds: 50_000_000)
            focusTransitioning = false
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
