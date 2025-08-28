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
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack {
                    HomeHeaderView(focusedItem: $focusedItem)
                    
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.carouselDisplayNameList, id: \.self) { displayName in
                            Text(displayName)
                                .font(.title2)
                            ScrollView(.horizontal) {
                                LazyHGrid(rows: [GridItem(.fixed(160), spacing: 20)]) {
                                    ForEach(0..<10, id: \.self) { _ in
                                        VStack {
                                            Button {} label: {
                                                VStack {
                                                    Image(systemName: "movieclapper")
                                                        .resizable()
                                                        .frame(width: 80, height: 80)
                                                        .padding()
                                                    
                                                    Text("Movie")
                                                    //.foregroundColor(isFocused ? .green : .white)
                                                }
                                                .frame(width: 120, height: 140)
                                                //.background(isFocused ? Color.gray.opacity(0.4) : Color.clear)
                                            }
                                            .buttonStyle(.plain)
                                            .contentShape(Rectangle())
                                        }
                                        .padding()
                                    }
                                }
                                //.focusSection()
                            }
                        }
                        .padding(.leading)
                    }
                    .task {
                        await viewModel.loadCarouselGroup()
                    }
                }
            }
        }
    }
}

#Preview {
    //HomeView()
}
