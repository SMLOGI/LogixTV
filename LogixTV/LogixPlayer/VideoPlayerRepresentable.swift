//
//  VideoPlayerRepresentable.swift
//  News18AppleTV
//
//  Created by Mohan Sivaram Ramasamy on 05/11/24.
//

import Foundation
import SwiftUI

struct PlayerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PlayerContainerViewController
    @State var playerController: PlayerContainerViewController

    func makeUIViewController(context: Context) -> PlayerContainerViewController {

        return playerController
    }

    func updateUIViewController(_ uiViewController: PlayerContainerViewController, context: Context) {
    }
}

class PlayerContainerViewController: UIViewController {
    public lazy var videoView: UIView = {
        let videoView = UIView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)

        NSLayoutConstraint.activate([
            videoView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor),
            videoView.topAnchor.constraint(equalTo: view.topAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
        return videoView
    }()

    // MARK: - View controller lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }

}
