//
//  HomeView.swift
//  LogixTV
//
//  Created by Subodh  on 04/08/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @FocusState.Binding var focusedItem: FocusTarget?
    @EnvironmentObject var globalNavState: GlobalNavigationState

    // Full screen header height
    private let headerHeight: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .top) {
                
                // MARK: Parallax Header
                GeometryReader { geo in
                    let offset = geo.frame(in: .global).minY
                    
                    HomeHeaderView(focusedItem: $focusedItem, homeViewModel: viewModel)
                        .frame(height: max(headerHeight, headerHeight + offset)) // expands on pull
                        .offset(y: offset > 0 ? -offset : 0) // parallax scroll
                }
                .frame(height: headerHeight)
                
                // MARK: Transparent Content
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.carouselGroups, id: \.name) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Section(group.displayName) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: .zero) {
                                        if let items = viewModel.carousels[group.name] {
                                            ForEach(items, id: \.id) { item in
                                                HStack(spacing: 0) {
                                                    CarouselCardButtonView(item: item, group: group, focusedItem: $focusedItem)
                                                }
                                                .padding(20)
                                            }
                                        }
                                        
                                    }
                                    .padding(.horizontal)
                                    .focusSection()
                            }
                            .padding()
 
                            }
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        }
                        .padding(.top, 16)
                        .focusSection()
                    }
                }
                .padding(.top, headerHeight - 320) // aligns first section at bottom of header
                .padding(.leading, 60)
                .focusSection()
                .onMoveCommand { dir in
                    if dir == .up {
                        globalNavState.lastFocus = focusedItem
                        focusedItem = .pageDot
                        
                    }
                    if dir == .left {
                        // go back to sidebar
                       // focusedItem = .menu(0)
                    }
                }
                .task {
                    await viewModel.loadCarouselGroup()
                    await viewModel.loadCarouselContents()
                }

            }
        }
        .edgesIgnoringSafeArea(.top)

    }
}

#Preview {
    //HomeView()
}
