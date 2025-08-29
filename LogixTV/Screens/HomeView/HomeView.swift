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
                    ForEach(viewModel.carouselDisplayNameList, id: \.self) { displayName in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(displayName)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: [GridItem(.fixed(160), spacing: 20)]) {
                                    ForEach(0..<10, id: \.self) { _ in
                                        Button {
                                            // action
                                        } label: {
                                            VStack {
                                                Image(systemName: "movieclapper")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80, height: 80)
                                                    .padding()
                                                
                                                Text("Movie")
                                                    .foregroundColor(.white)
                                            }
                                            .frame(width: 120, height: 160)
                                            .background(
                                                Color.black.opacity(0.4) // only cell bg
                                                    .cornerRadius(12)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(.top, headerHeight - 200) // aligns first section at bottom of header
                .task {
                    await viewModel.loadCarouselGroup()
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}


#Preview {
    //HomeView()
}
