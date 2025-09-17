//
//  BitrateSelectorView.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 27/05/25.
//

import SwiftUI
import AVKit

struct BitrateOption: Identifiable {
    let id = UUID()
    let bitrate: Double?  // `nil` for Automatic
    let label: String
}

struct BitrateSelectionView: View {
    @ObservedObject var controller: VideoPlayerController
    @Binding var showBitrate: Bool

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Automatic")
                    .padding(.horizontal, 10)
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(controller.selectedBitrate == 0 ? .green : .clear)
                    .padding(.trailing, 10)
            }
            .frame(height: 35)
            .contentShape(Rectangle()) // Ensures full row is tappable
            .onTapGesture {
                controller.setBitrate(0) // 0 = Auto
                controller.selectedBitrate = 0
                showBitrate = false
            }
            Divider()
            ForEach(controller.availableBitrates, id: \.self) { bitrate in
                VStack(spacing: 0) {
                    HStack {
                        Text(label(for: bitrate))
                            .padding(.horizontal, 10)
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(controller.selectedBitrate == bitrate ? .green : .clear)
                            .padding(.trailing, 10)
                    }
                    .frame(height: 35)
                    .contentShape(Rectangle()) // Ensures full row is tappable
                    .onTapGesture {
                        controller.setBitrate(bitrate)
                        controller.selectedBitrate = bitrate
                        showBitrate = false
                    }
                    
                    Divider()
                }
            }
        }
        .padding()
    }
    func label(for bitrate: Double) -> String {
        switch bitrate {
        case ..<500_000:
            return "Low (240p)"
        case ..<1_000_000:
            return "Medium (360p)"
        case ..<2_000_000:
            return "SD (480p)"
        case ..<3_500_000:
            return "HD (720p)"
        case ..<5_000_000:
            return "Full HD (1080p)"
        case ..<8_000_000:
            return "Ultra HD (1440p)"
        default:
            return "4K (2160p)"
        }
    }

}
