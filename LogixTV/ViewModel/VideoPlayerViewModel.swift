//
//  VideoPlayerViewModel.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 15/05/25.
//

import Foundation

class VideoPlayerViewModel: ObservableObject {
    @Published var videoURL: URL?
    @Published var movies: [Movie]?

    func fetchVideoURL(videoID: String) async {
            DispatchQueue.main.async {
                //  self.videoURL = URL(string: contentUrl)
                self.videoURL = URL(string: "http://sample.vodobox.com/planete_interdite/planete_interdite_alternate.m3u8")!
            }
    }
}
