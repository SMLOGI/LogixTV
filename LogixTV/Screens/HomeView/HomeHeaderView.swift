//
//  HomeHeaderView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 26/08/25.
//

import Foundation
import SwiftUI

struct HomeHeaderView: View {
    // pass binding from parent: HomeHeaderView(focusedItem: $focusedItem)
    @FocusState.Binding var focusedItem: FocusTarget?
    
    @StateObject private var viewModel = CarouselViewModel()

    // Optional content you might want to expose
    var title: String = "Mission Impossible"
    var subtitle: String = "Mission: Impossible The Final Reckoning is an upcoming American action spy film directed by Christopher McQuarrie..."

    var body: some View {
        HStack(alignment: .center, spacing: 40) {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)

                Text(subtitle)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.body)
                    .frame(maxWidth: 500)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    print("Play tapped")
                    // handle play action
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                        Text("Play").bold()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple))
                    .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .focused($focusedItem, equals: .playButton)
                .accessibilityLabel("Play")
            }
            .padding(.leading, 60)

            Spacer()
        }
        .padding(.top, 100)
        .background(Color.red)
        .task {
            await viewModel.loadCarousel()
        }
    }
}
