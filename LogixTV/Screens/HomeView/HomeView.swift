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
    @Binding var isContentLoaded: Bool
    // Full screen header height
    private let headerHeight: CGFloat = UIScreen.main.bounds.height
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                
                // MARK: Parallax Header
                GeometryReader { geo in
                    let offset = geo.frame(in: .global).minY
                    
                    HomeHeaderView(focusedItem: $focusedItem, homeViewModel: viewModel)
                        .frame(height: max(headerHeight, headerHeight + offset)) // expands on pull
                        .offset(y: offset > 0 ? -offset : 0) // parallax scroll

                }
                .frame(height: UIScreen.main.bounds.height - 260)
                
                MovieCollectionView(viewModel: viewModel, focusedItem: $focusedItem)
                    .padding(.leading, 80)
                
                .task {
                    await viewModel.loadCarouselGroup()
                    await viewModel.loadCarouselContents()
                    print("**** content loaded")
                    self.isContentLoaded = true
                }

            }
        }
        .edgesIgnoringSafeArea(.top)

    }
}

#Preview {
    //HomeView()
}
