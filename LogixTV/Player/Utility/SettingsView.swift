//
//  SettingsView.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 21/05/25.
//

import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Binding var showSettings: Bool
    @Binding var captionsEnabled: Bool
    @ObservedObject var controller: VideoPlayerController

    var body: some View {
        if showSettings {
            ScrollView {
                VStack(spacing: 0) {
                    OptionSectionView(
                        title: "Select Sub Title",
                        options: controller.subtitleOptions ?? [],
                        selectedOption: controller.selectedSubtitleOption,
                        onSelect: { option in
                            showSettings = false
                            captionsEnabled = true
                            controller.selectLanguage(option: option)
                        }
                    )
                    
                    OptionSectionView(
                        title: "Select Audio",
                        options: controller.audioOptions ?? [],
                        selectedOption: controller.selectedAudioOption,
                        onSelect: { option in
                            showSettings = false
                            controller.selectAudio(option: option)
                        }
                    )
                }
            }
            .frame(width: 300, height: 250)
            .background(Color.white)
        }
    }
}

struct OptionSectionView: View {
    let title: String
    let options: [AVMediaSelectionOption]
    let selectedOption: AVMediaSelectionOption?
    let onSelect: (AVMediaSelectionOption) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .bold()
                .foregroundColor(.white)
                .padding(5)
                .frame(maxWidth: .infinity)
                .background(Color.blue)

            ForEach(options, id: \.displayName) { option in
                VStack(spacing: 0) {
                    HStack {
                        Text(option.displayName)
                            .padding(.horizontal, 10)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(option.displayName == selectedOption?.displayName ? .green : .clear)
                            .padding(.trailing, 10)
                    }
                    .frame(height: 35)
                    .contentShape(Rectangle()) // Ensures full row is tappable
                    .onTapGesture {
                        onSelect(option)
                    }

                    Divider()
                }
            }
        }
    }
}
