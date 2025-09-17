//
//  VideoSettingsPopupView.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 20/05/25.
//

import SwiftUI
import AVFoundation

struct VideoSettingsPopupView: View {
    @Binding var isPresented: Bool
    @Binding var selectedAudio: AVMediaSelectionOption?
    @Binding var selectedSubtitle: AVMediaSelectionOption?
    @Binding var selectedResolution: String

    let asset: AVAsset
    let playerItem: AVPlayerItem

    @State private var audioOptions: [AVMediaSelectionOption] = []
    @State private var subtitleOptions: [AVMediaSelectionOption] = []
    @State private var showAudioSheet = false
    @State private var showSubtitleSheet = false

    let resolutionOptions = ["Auto", "1080p", "720p", "480p"]

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { isPresented = false }

            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title3.bold())
                    .foregroundColor(.white)

                // Audio
                Button(action: { showAudioSheet.toggle() }) {
                    HStack {
                        Text("Audio: \(selectedAudio?.displayName ?? "Select")")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                }

                // Subtitle
                Button(action: { showSubtitleSheet.toggle() }) {
                    HStack {
                        Text("Subtitle: \(selectedSubtitle?.displayName ?? "Off")")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                }

                // Resolution
                Picker("Resolution", selection: $selectedResolution) {
                    ForEach(resolutionOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Button("Close") {
                    isPresented = false
                }
                .padding(.top)
            }
            .padding()
            .background(Color.black)
            .cornerRadius(16)
            .padding(.horizontal)
        }
        .onAppear {
            loadMediaOptions()
        }
        .sheet(isPresented: $showAudioSheet) {
            MediaSelectionListView(options: audioOptions, selectedOption: $selectedAudio, title: "Select Audio")
        }
        .sheet(isPresented: $showSubtitleSheet) {
            MediaSelectionListView(options: subtitleOptions, selectedOption: $selectedSubtitle, title: "Select Subtitle")
        }
    }

    private func loadMediaOptions() {
        let audioGroup = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .audible)
        let subtitleGroup = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)

        audioOptions = audioGroup?.options ?? []
        subtitleOptions = subtitleGroup?.options ?? []
    }
}
