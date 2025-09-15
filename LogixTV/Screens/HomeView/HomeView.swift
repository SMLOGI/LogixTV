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
                            Section(group.displayName) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: .zero) {
                                        if let items = viewModel.carousels[group.name] {
                                            ForEach(items, id: \.id) { item in
                                                HStack(spacing: 0) {
                                                    CarouselCardButtonView(item: item, focusedItem: $focusedItem)
                                                }
                                                .padding(20)
                                            }
                                        }
                                        
                                    }
                                    .padding(.horizontal)
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
                .padding(.top, headerHeight - 400) // aligns first section at bottom of header
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
    @FocusState.Binding var focusedItem: FocusTarget?
    var body: some View {
        Button(action: {
            // handle card tap
        }) {
            VStack(alignment: .leading) {
                if let imageUrl = item.imageURL(for: .landscape16x9) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(16/9, contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                } else {
                    Rectangle()
                        .fill(Color.gray)
                }
            }
            .frame(height: 150)
            .cornerRadius(12)
        }
        .focused($focusedItem, equals: .carouselItem(item.id))
        .buttonStyle(.card)
    }
}

#Preview {
    //HomeView()
}
