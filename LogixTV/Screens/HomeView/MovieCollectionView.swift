//
//  MovieCollectionView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 23/09/25.
//

import Foundation
import SwiftUI

struct MovieCollectionView: View {
    @ObservedObject var viewModel: HomeViewModel
    @FocusState.Binding var focusedItem: FocusTarget?
    @EnvironmentObject var globalNavState: GlobalNavigationState


    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(viewModel.carouselGroups, id: \.name) { group in
                    if let items = viewModel.carousels[group.name], !items.isEmpty {
                        MovieRowView(
                            title: group.displayName,
                            items: items,
                            group: group,
                            focusedItem: $focusedItem
                        ) {
                            globalNavState.activeScreen = .player
                        }
                    }
                }
            }
            .padding(.top)
        }
        .background(Color.clear.ignoresSafeArea())
    }
}

private struct MovieRowView: View {
    let title: String
    let items: [CarouselContent]
    let group: CarouselGroupData
    @FocusState.Binding var focusedItem: FocusTarget?
    let onItemSelect: () -> Void

    var body: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 40) {
                    ForEach(items, id: \.id) { item in
                        CarouselCardButtonView(
                            item: item,
                            group: group,
                            focusedItem: $focusedItem,
                        )
                        .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 40)
            }
            .focusSection()
        } header: {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.leading, 40)
        }
    }
}
