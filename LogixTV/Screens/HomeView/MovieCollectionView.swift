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

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.carouselGroups, id: \.name) { group in
                        
                        Section {
                            // Horizontal row of movies
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
                                .padding(.horizontal, 40)
                            }
                            .focusSection()   // ✅ focus area per row
                        } header: {
                            // Section title
                           Text(group.displayName)
                                .font(.headline)            // set font
                                .foregroundColor(.gray)     // set color
                                .padding(.leading, 40)      // padding
                        }

                        
                    }
                }
                .padding(.top, .zero)
            }
        }
        .background(Color.clear.ignoresSafeArea())
    }
}
