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
    
    // Full screen header height
    private let headerHeight: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .top) {
                
                // MARK: Parallax Header
                GeometryReader { geo in
                    let offset = geo.frame(in: .global).minY
                    
                    HomeHeaderView(focusedItem: $focusedItem)
                        .frame(height: max(headerHeight, headerHeight + offset)) // expands on pull
                        .offset(y: offset > 0 ? -offset : 0) // parallax scroll
                }
                .frame(height: headerHeight)
                
                // MARK: Transparent Content
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.carouselGroups, id: \.name) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(group.displayName)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    if let items = viewModel.carousels[group.name] {
                                        ForEach(items, id: \.id) { item in
                                            CarouselCardButtonView(item: item)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 16)
                        .focusSection()
                        .onMoveCommand { dir in
                            if dir == .left {
                                // go back to sidebar
                                focusedItem = .menu(0)
                            }
                        }
                    }
                }
                .padding(.top, headerHeight - 200) // aligns first section at bottom of header
                .task {
                    await viewModel.loadCarouselGroup()
                    await viewModel.loadCarouselContents()
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct CarouselCardButtonView: View {
    let item: CarouselContent
    
    var body: some View {
        Button(action: {
            // handle card tap
        }) {
            VStack(alignment: .leading) {
                if let images = item.images {
                    let imageUrl = images.count > 1 ? images[1].imageLink : images.first?.imageLink
                    if let imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(3/4, contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 200)
                        .cornerRadius(12)
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: 200)
                            .cornerRadius(12)
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 200)
                        .cornerRadius(12)
                }
            }
        }
        .frame(width: 200)
        .buttonStyle(.plain)
    }
}

#Preview {
    //HomeView()
}
