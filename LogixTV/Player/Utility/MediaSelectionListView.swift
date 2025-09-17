//
//  MediaSelectionListView.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 20/05/25.
//

import SwiftUI
import AVFoundation

struct MediaSelectionListView: View {
    let options: [AVMediaSelectionOption]
    @Binding var selectedOption: AVMediaSelectionOption?
    let title: String

    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                    }) {
                        HStack {
                            Text(option.displayName)
                            Spacer()
                            if selectedOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Button("Off") {
                    selectedOption = nil
                }
            }
            .navigationTitle(title)
        }
    }
}
