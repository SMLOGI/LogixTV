//
//  VideoPlayerController.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradip on 15/05/25.
//

import AVKit
import Foundation
import AVFoundation
import Combine
//import GoogleInteractiveMediaAds

class VideoPlayerController: NSObject, ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var availableBitrates: [Double] = []
    @Published var selectedBitrate: Double = 0
    
    
    private var timeObserver: Any?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerView: UIView?
    private var pipController: AVPictureInPictureController?
    /*
    var contentPlayhead: IMAAVPlayerContentPlayhead?
    var adsLoader: IMAAdsLoader?
    var adsManager: IMAAdsManager?*/
    
    var isPipSupported: Bool {
        AVPictureInPictureController.isPictureInPictureSupported()
    }
    /// Optional: Expose current AVPlayer if needed
    var currentPlayer: AVPlayer? {
        return player
    }
    func currentVideoURL() -> URL? {
        return (player?.currentItem?.asset as? AVURLAsset)?.url
    }
    
    var subtitleOptions: [AVMediaSelectionOption]? {
        return self.player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible)?.options
    }
    var audioOptions: [AVMediaSelectionOption]? {
        return self.player?.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .audible)?.options
    }
    
    var selectedSubtitleOption: AVMediaSelectionOption?
    var selectedAudioOption: AVMediaSelectionOption?
    let speeds: [Float] = [0.5, 1.0, 1.5, 2.0]
    var currentSpeed: Float = 1.0

    
    /// Attach the controller to an AVPlayer instance
    func attach(to player: AVPlayer , playerLayer: AVPlayerLayer, playerView: UIView) {
        self.player = player
        self.playerLayer = playerLayer
        self.playerView = playerView
        // Set up your content playhead and contentComplete callback.
       // self.contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(contentDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        // Add periodic time observer to update currentTime
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            let seconds = time.seconds
            if !seconds.isNaN && seconds.isFinite {
                DispatchQueue.main.async {
                    self.currentTime = seconds
                }
            }
        }
        
        // Observe when the duration becomes available
        if let item = player.currentItem {
            let asset = item.asset
            asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                var error: NSError?
                let status = asset.statusOfValue(forKey: "duration", error: &error)
                if status == .loaded {
                    let durationInSeconds = asset.duration.seconds
                    if durationInSeconds.isFinite && !durationInSeconds.isNaN {
                        DispatchQueue.main.async {
                            self.duration = durationInSeconds
                        }
                    }
                }
            }
            
        }
        
        self.fetchAvailableBitrates()
        self.setPip()
        
    }
    
    func setPip() {
        guard let playerLayer = self.playerLayer else { return }
        playerLayer.frame = UIScreen.main.bounds
        if AVPictureInPictureController.isPictureInPictureSupported() {
            self.pipController = AVPictureInPictureController(playerLayer: playerLayer)
            self.pipController?.delegate = self
            print("isPictureInPicturePossible: \(self.pipController?.isPictureInPicturePossible ?? false)")
        }
    }
    
    func startPictureInPicture() {
        guard let pipController = pipController, pipController.isPictureInPicturePossible else { return }
        pipController.startPictureInPicture()
    }
    
    func stopPictureInPicture() {
        pipController?.stopPictureInPicture()
    }
    /// Play the video
    func play() {
        player?.play()
        DispatchQueue.main.async {
            self.isPlaying = true
        }
    }
    
    /// Pause the video
    func pause() {
        player?.pause()
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    /// Seek to a specific time
    func seek(to seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: 600)
        player?.seek(to: time)
    }
    
    func seekForward(by seconds: Double = 10) {
        let newTime = min(currentTime + seconds, duration)
        seek(to: newTime)
    }
    
    func seekBackward(by seconds: Double = 10) {
        let newTime = max(currentTime - seconds, 0)
        seek(to: newTime)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
    }
    
    func toggleCaptions(enable: Bool) {
        guard let playerItem = self.player?.currentItem, let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            return
        }
        if enable {
            if let option = selectedSubtitleOption {
                playerItem.select(option, in: group)
            } else if let option = group.options.first {
                playerItem.select(option, in: group)
            }
        } else {
            playerItem.select(nil, in: group)
        }
    }
    func selectLanguage(option: AVMediaSelectionOption) {
        guard let playerItem = self.player?.currentItem, let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
            return
        }
        selectedSubtitleOption = option
        playerItem.select(option, in: group)
    }
    func selectAudio(option: AVMediaSelectionOption) {
        guard let playerItem = self.player?.currentItem, let group = playerItem.asset.mediaSelectionGroup(forMediaCharacteristic: .audible) else {
            return
        }
        selectedAudioOption = option
        playerItem.select(option, in: group)
    }
    func fetchAvailableBitrates() {
        guard let url = self.currentVideoURL() else {
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let playlist = String(data: data, encoding: .utf8),
                  error == nil else {
                print("Failed to fetch or decode playlist: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            var bitrates: [Double] = []
            let lines = playlist.components(separatedBy: .newlines)
            
            for line in lines where line.starts(with: "#EXT-X-STREAM-INF:") {
                if let bandwidth = self.parseBandwidth(from: line) {
                    bitrates.append(bandwidth)
                }
            }
            
            DispatchQueue.main.async {
                self.availableBitrates = bitrates.sorted()
            }
        }.resume()
    }
    
    /// Parses BANDWIDTH from #EXT-X-STREAM-INF line
    func parseBandwidth(from line: String) -> Double? {
        let list = line.components(separatedBy: ",")
        if let bandwidthString = list.first(where: { $0.contains("BANDWIDTH") }) {
            print(bandwidthString)
            let bandwidthList = bandwidthString.components(separatedBy: "=")
            if let bandwidthNum = bandwidthList.first(where: { !$0.contains("BANDWIDTH") }) {
                return Double(bandwidthNum)
            }
        }
        return nil
    }
    
    /// Sets a specific preferred bitrate on the AVPlayer (in bits per second)
    func setBitrate(_ bitrate: Double) {
        self.player?.currentItem?.preferredPeakBitRate = bitrate
        print("Set preferred peak bitrate to: \(bitrate)")
    }
    
    /// Prints current observed bitrate events from AVPlayer
    func printAccessLog() {
        guard let events = self.player?.currentItem?.accessLog()?.events else {
            print("No access log available.")
            return
        }
        for (index, event) in events.enumerated() {
            print("--- Event #\(index + 1) ---")
            print("Observed bitrate: \(event.observedBitrate) bps")
            print("Indicated bitrate: \(event.indicatedBitrate) bps")
            print("URI: \(event.uri ?? "N/A")")
            print("Duration: \(event.durationWatched) seconds")
        }
    }
    
    func setPlaybackSpeed(to speed: Float) {
        currentSpeed = speed
        if  self.player?.timeControlStatus == .paused {
            self.player?.playImmediately(atRate: speed)
        } else {
            self.player?.rate = speed
        }
    }
    /*
    func requestAds() {
        let adTagStr = StringConstants.preMidPostRoll
        
        guard let playerView = playerView,
              let viewController = viewController(for: playerView) else {
            print("❌ playerView or its viewController not found.")
            return
        }

        
        guard let adTagURL = URL(string: adTagStr) else { return }
        // Step 1: Create ad display container
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: playerView, viewController: viewController, companionSlots: nil)
        
        // Step2: create content playhead
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player!)
        
        // Step3: Create and assign adsLoader

        adsLoader = IMAAdsLoader()
        adsLoader?.delegate = self
        
        // Step 4: Request ads using adsLoader

        let adRequest = IMAAdsRequest(
            adTagUrl: adTagURL.absoluteString,
            adDisplayContainer: adDisplayContainer,
            contentPlayhead: contentPlayhead,
            userContext: nil
        )
        adsLoader?.requestAds(with: adRequest)
    }
    @objc func contentDidFinishPlaying(_ notification: Notification) {
        self.adsLoader?.contentComplete()
        
    } */
    func viewController(for view: UIView) -> UIViewController? {
        var responder: UIResponder? = view
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}
extension VideoPlayerController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ controller: AVPictureInPictureController) {
        print("Will start PiP")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ controller: AVPictureInPictureController) {
        print("Did stop PiP")
    }
    
    func pictureInPictureController(_ controller: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Failed to start PiP: \(error.localizedDescription)")
    }
}
/*
extension VideoPlayerController: IMAAdsLoaderDelegate, IMAAdsManagerDelegate {
        
    // MARK: - IMAAdsLoaderDelegate
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith data: IMAAdsLoadedData) {
        print("✅ Received stream manager")
        adsManager = data.adsManager
        // self.cuePoints = adsManager?.adCuePoints as? [Int]
        adsManager?.delegate = self
        adsManager?.initialize(with: nil)
    }

    func adsLoader(_ loader: IMAAdsLoader, failedWith errorData: IMAAdLoadingErrorData) {
        print("❌ Failed to load stream: \(errorData.adError.message ?? "Unknown error")")
        play()
    }

    // MARK: - IMAAdsManagerDelegate
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        print("📺 Ad Event: \(event.typeString)")
        switch event.type {
        case .LOADED:
            adsManager.start() // Start ad playback
        case .ALL_ADS_COMPLETED:
            play() // Resume content after all ads
        case .SKIPPED:
            print("Ad skipped!")
            play() // Resume content immediately
        case .LOG:
            print("Advertisement log's : \((event.adData?["logData"] as? String) ?? "unknow")")
        default:
            break
        }
    }

    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        print("❌ Stream error: \(error.message ?? "Unknown error")")
        play()
    }

    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        pause()
    }

    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        play()
    }
        
}*/
