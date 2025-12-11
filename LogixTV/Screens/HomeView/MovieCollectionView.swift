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
                            globalNavState.activeScreen = .player(.home)
                        }
                    }
                }
            }
            .padding(.top)
        }
        .background(Color.clear.ignoresSafeArea())
        .onAppear {
            print("MovieCollectionView")
            if let lastFocus = globalNavState.lastFocus {
                print("lastFocus = \(lastFocus)")
                focusedItem = lastFocus
            }
        }
    }
}

private struct MovieRowView: View {
    let title: String
    let items: [CarouselContent]
    let group: CarouselGroupData
    @FocusState.Binding var focusedItem: FocusTarget?
    let onItemSelect: () -> Void

    private var type: CarouselImageType {
        items.first?.availableImageType ?? .landscape16x9
    }

    private var noOfCells: CGFloat {
        switch type {
        case .landscape16x9: return 4
        case .portrait3x4:   return 5
        case .square1x1:     return 6
        }
    }

    private var cardSize: CGSize {
        CarouselLayoutCalculator.cardSize(for: type, noOfCells: noOfCells)
    }

    var body: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 50) {
                    ForEach(items, id: \.id) { item in
                        CarouselCardButtonView(
                            item: item,
                            group: group,
                            focusedItem: $focusedItem,
                            cardSize: cardSize,
                            completion: onItemSelect
                        )
                        .id(item.id)
                        .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 40)
            }
            .id(group.name)
            .focusSection()

        } header: {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.leading, 40)
        }
    }
}
struct CarouselLayoutCalculator {

    static func cardSize(
        for type: CarouselImageType,
        noOfCells: CGFloat,
        horizontalPadding: CGFloat = 40,
        spacing: CGFloat = 40
    ) -> CGSize {

        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = (noOfCells - 1) * spacing + (horizontalPadding * 2)
        let width = (screenWidth - totalSpacing) / noOfCells
        let height = width / type.aspectRatio
        return CGSize(width: width, height: height)
    }
}
