//
//  HomeView.swift
//  LogixTV
//
//  Created by Subodh  on 04/08/25.
//

import SwiftUI

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
    @State private var selectedIndex = 0
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.6), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 40) {
                // MARK: - Header Section
                HStack(alignment: .center, spacing: 40) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Mission Impossible")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        Text("Mission: Impossible The Final Reckoning is an upcoming American action spy film directed by Christopher McQuarrie...")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.body)
                            .frame(maxWidth: 500)
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Play")
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.leading, 60)
                    
                    Spacer()
                }
                .padding(.top, 100)
                
                // MARK: - Page Dots (Own Section ✅)
               /* HStack(spacing: 12) {
                    ForEach(0..<7, id: \.self) { index in
                        Circle()
                            .fill(index == selectedIndex ? Color.white : Color.gray)
                            .frame(width: 12, height: 12)
                            .scaleEffect(focusedItem == .pageDot(index) ? 1.5 : 1.0)
                            .focused($focusedItem, equals: .pageDot(index))
                            .onTapGesture {
                                selectedIndex = index
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .focusSection() // ✅ isolated section for dots*/
                
                // MARK: - Bollywood Movies (Own Section ✅)
                VStack(alignment: .leading, spacing: 20) {
                    Text("Bollywood Movies")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 60)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 40) {
                            ForEach(items) { item in
                                VStack(spacing: 10) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(focusedItem == .carouselItem(item.id) ? Color.white : Color.gray.opacity(0.7))
                                        .frame(width: 200, height: 280)
                                        .overlay(
                                            Image(systemName: item.imageName)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .foregroundColor(focusedItem == .carouselItem(item.id) ? .black : .white)
                                        )
                                        .scaleEffect(focusedItem == .carouselItem(item.id) ? 1.1 : 1.0)
                                        .animation(.easeInOut(duration: 0.2), value: focusedItem)
                                    
                                    Text(item.title)
                                        .foregroundColor(.white)
                                        .font(.caption)
                                }
                            .focused($focusedItem, equals: .carouselItem(item.id))
                            }
                        }
                        .padding(.horizontal, 60)
                    }
                    .focusSection() // ✅ isolated section for carousel
                }
            }
            .padding(.bottom, 60)
        }
        .focusSection() // root fallback section
    }
}

#Preview {
    //HomeView()
}
