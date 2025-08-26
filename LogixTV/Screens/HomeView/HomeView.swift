//
//  HomeView.swift
//  LogixTV
//
//  Created by Subodh  on 04/08/25.
//

import SwiftUI

// MARK: - Model
struct CarouselItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

struct HomeView: View {
    let items: [CarouselItem] = (1...10).map {
        CarouselItem(title: "Movie \($0)", imageName: "film")
    }
    
    @FocusState.Binding var focusedItem: FocusTarget?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            HomeHeaderView(focusedItem: $focusedItem, title: "Featured Movies")
            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(160), spacing: 20)]) {
                    ForEach(items) { item in
                        FocusableCell(
                            item: item,
                            focusedItem: $focusedItem
                        ) {
                            print("Tapped \(item.title)")
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    //HomeView()
}
