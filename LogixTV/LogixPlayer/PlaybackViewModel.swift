//
//  PlaybackViewModel.swift
//  News18AppleTV
//
//  Created by Mohan Sivaram Ramasamy on 05/11/24.
//

import Foundation
import UIKit
import LogixPlayerSDK
import Combine
import AVFoundation

enum LogixPlayerSDKError: Error {
    case configuration
    case other
}

struct PlayerProgress {
    var totalDuration: Double = 0.0
    var currentDuration: Double = 0.0
}

enum PlayerState {
    case showingAds
    case hiddenAds
    case readyPlayback
    case startedPlayback
    case endedPlayback
    case errorPlayback
    case pauseplayback
    case resumedPlayback
    case none
}

extension PlayerState: CustomStringConvertible {
    var description: String {
        switch self {
        case .showingAds: return "Showing Ads"
        case .hiddenAds: return "Hidden Ads"
        case .readyPlayback: return "Ready for Playback"
        case .startedPlayback: return "Started Playback"
        case .endedPlayback: return "Ended Playback"
        case .errorPlayback: return "Error in Playback"
        case .pauseplayback: return "Paused Playback"
        case .resumedPlayback: return "Resumed Playback"
        case .none: return "None"
        }
    }
}

enum VideoQualityName: String, CaseIterable {
    case automatic = "Auto"
    case lowQuality = "Low (240p)"
    case mediumQuality = "Medium (360p)"
    case highQuality = "High (480p)"
    case hdQuality = "HD (720p)"
    case fullHDQuality = "Full HD (1080p)"
    case unknown = "Unknown"

    var description: String {
        return self.rawValue
    }

    // Suggested bandwidth ranges based on provided quality levels
    var bandwidthRange: ClosedRange<Int>? {
        switch self {
        case .automatic:
            return nil
        case .lowQuality:
            return 200_000...500_000 // 0.2 - 0.5 Mbps
        case .mediumQuality:
            return 500_000...900_000 // 0.47 - 0.88 Mbps
        case .highQuality:
            return 900_000...2_000_000 // 0.88 - 2 Mbps
        case .hdQuality:
            return 2_000_000...4_000_000 // 2.79 - 4 Mbps
        case .fullHDQuality:
            return 4_000_000...Int.max // 4.46 Mbps and above
        case .unknown:
            return nil
        
        }
    }
}

class PlaybackViewModel: ObservableObject, Observable {
    @Published var progress: PlayerProgress?
    @Published var playerState: PlayerState = .none
    @Published var sdkError: LogixPlayerSDKError?
    @Published var adPositions: [Double] = []
    @Published var wasPaused: Bool = false
    @Published var isShowingAd: Bool = true
    var liveData: VideoData?

    private var observers = Set<AnyCancellable>()
    private var playerFactoryProducer: PlayerFactoryProducer?
    private var mediaPlayer: BasicMediaPlayer?
    private var playerView: UIView!

    private var cancellables = Set<AnyCancellable>()
    //let appManager = AppManager()
    
    @Published var streamQualities: [IMediaStreamQuality]?
    var selectedQuality: IMediaStreamQuality? {
        didSet {
            if let selectedQuality {
                setStreamQuality(quality: selectedQuality)
            }
        }
    }
    func preparePlayer(with videoData: VideoData, playerContainerView: UIView, showAds: Bool = false) {
        liveData = videoData
        let adTagURLString = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpost&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator="
        self.playerView = playerContainerView
            liveData = nil
            self.prepareAsset(
                videoURL: videoData.contentUrl,
                adTagUrl: adTagURLString,
                showAds: showAds
            )
            self.sdkError = nil
    }
}

// MARK: Setup
extension PlaybackViewModel {
    private func prepareAsset(videoURL: String, adTagUrl: String?, showAds: Bool = false) {
        let imaConfig = IMAConfig()
        if let adTagUrl, showAds {
            imaConfig.adTagUrl = adTagUrl
        }
        let playbackAsset = PlaybackAsset(category: .standardStreamUrl,
                                          partnerType: .logituit,
                                          playableMediaType: .vod,
                                          contentProtectionType: .clearStream, imaConfig: imaConfig)

        let pluginConfig = PlugInConfiguration(supportedPlugins: [.googleIMA])
        let playerConfigBuilder = PlayerConfigurationBuilder(plugInConfiguration: pluginConfig,
                                                             isBuildSucessfully: true,
                                                             enableSpotAdFeature: false,
                                                             companionDelay: 0,
                                                             adMetadata: nil)
        self.playerFactoryProducer = PlayerFactoryProducer(anyPlayabeMedia: playbackAsset,
                                                           playerType: .logixPlayer,
                                                           networkClient: nil)
        let standardStreamConfiguration = StandardStreamConfiguration(streamUrl: videoURL )
        let playerBuilder = self.setupPlayerBuilder(with: standardStreamConfiguration, playableMediaType: .vod)
        self.playerFactoryProducer?.createPlayer(playerBuilder: playerBuilder!,
                                                 playerConfigBuilder: playerConfigBuilder,
                                                 parentView: self.playerView)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure:
                break
            case .finished:
                break
            }
        }, receiveValue: { mediaPlayer in
            self.mediaPlayer = mediaPlayer
            if let player = self.mediaPlayer {
                player.setContentMode(mode: .scaleAspectFit)
                self.mute()
            }
            self.addPlayerEventListener()
            self.addPlayerAdEventsListener()
        })
        .store(in: &self.observers)
    }

    private func setupPlayerBuilder(with standardStreamConfiguration: StandardStreamConfiguration?,
                                    playableMediaType: PlayableMediaType?) -> LGPlayerBuilder? {
        let playerConfig  = PlayerConfiguration()
        let networkConfig = NetworkConfiguration(accessToken: "",
                                                 uniqueId: "",
                                                 deviceId: "",
                                                 platform: "iosmobile",
                                                 playbackrightsURL: "",
                                                 timeoutInterval: 300)
        let partnerConfiguration = PartnerConfiguration(playbackrightsURL: "",
                                                        fpsLicenseURL: "",
                                                        accessToken: "",
                                                        getChannelURL: "",
                                                        platform: "iosmobile")
        return LGPlayerBuilder(playerConfiguration: playerConfig,
                               networkConfiguration: networkConfig,
                               partnerConfiguration: partnerConfiguration,
                               standardStreamConfiguration: standardStreamConfiguration,
                               playerSettingsConfiguration: nil,
                               isBuildSucessfully: true)
    }
}

// MARK: Actions
extension PlaybackViewModel {
    func play() {
        self.mediaPlayer?.play()
    }

    func pause() {
        self.mediaPlayer?.pause()
    }

    func mute() {
        self.mediaPlayer?.setIsPlayerMuted(true)
    }

    func unMute() {
        self.mediaPlayer?.setIsPlayerMuted(false)
    }

    func isPlaying() -> Bool {
        return (self.mediaPlayer?.isPlaying ?? false)
    }
    func isShowingAds() -> Bool {
        return (playerState == .showingAds)
    }

    func seekToPosition(value: Float) {
        self.mediaPlayer?.seekTo(position: TimeInterval(value), completion: { _ in

        })
    }
    func seekToLiveEdge() {
        self.play()
        self.mediaPlayer?.seekToLiveEdge()
    }
    func goToLive(){
        self.mediaPlayer?.seekToLiveEdge()
    }

    func seekForward(value: Float) {
        self.mediaPlayer?.seekForward(duration: TimeInterval(value), completion: { _ in

        })
    }

    func seekBackward(value: Float) {
        self.mediaPlayer?.seekBackward(duration: TimeInterval(value), completion: { _ in

        })
    }

    func destroyPlayer() {
        // 1. Stop & destroy the media player
        mediaPlayer?.destroy()
        
        // 2. Cancel all Combine observers
        observers.forEach { $0.cancel() }
        observers.removeAll()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        // 3. Remove any subviews on the main thread
        DispatchQueue.main.async {
            self.playerView?.subviews.forEach { $0.removeFromSuperview() }
        }
        
        // 4. Nil out references and reset state
        mediaPlayer = nil
        playerFactoryProducer = nil
        liveData = nil
        progress = nil
        playerState = .none
        adPositions = []
        wasPaused = false
    }
    func setStreamQuality(quality: IMediaStreamQuality) {
        self.mediaPlayer?.setPreferredVideoStreamQuality(quality: quality)
    }
    func setPrefferedBitrate(bitrate: Double) {
        self.mediaPlayer?.setPreferredPeakBitrate(bitrate: bitrate)
    }
}

// MARK: EventListeners
extension PlaybackViewModel {
    private func addPlayerEventListener() {
        progress = PlayerProgress()
        self.mediaPlayer?.playerEventPublisher?
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    debugPrint("Oops error \(error)")
                case .finished:
                    debugPrint("event received")
                }
            } receiveValue: { [weak self] result in
                guard self != nil else {
                    return
                }
                self?.addListenerForPlayerEvents(result: result)
                self?.addListenerForPlayerEventsContinuation(result: result)
            }
            .store(in: &self.observers)
    }

    func addListenerForPlayerEvents(result: IPlayerEvent) {
        switch result {
        case _ as PlayBackReady:
            debugPrint("Playback Ready")
                // Check Each time playback is ready for the live content call seekToLive which play the latest live content
            playerState = .readyPlayback
        case _ as Play:
            debugPrint("Playback Started")
            if wasPaused {
                     playerState = .resumedPlayback
                     wasPaused = false
                 } else {
                     playerState = .startedPlayback
                 }        case _ as Pause:
            wasPaused = true
            playerState = .pauseplayback
        case let playerProgress as LogixPlayerSDK.Progress:
            if let currentDuration = playerProgress.currentDuration {
                progress?.currentDuration = currentDuration
            }
            if let totalDuration = playerProgress.totalDuration {
                progress?.totalDuration = totalDuration
            }
            
        case let qualitiesEvent as StreamQualitiyListAvailable:
            if let qualities = qualitiesEvent.mediaStreamQualities {
                if streamQualities == nil {
                    streamQualities = qualities
                }
            }
        case _ as EndedPlay:
            debugPrint("Playback Ended")
            playerState = .endedPlayback
        case let sdkerror as PlayerErrorEvent:
        switch sdkerror.payloadData["error"] {
        case _ as PlayerConfigurationError:
            self.sdkError = .configuration
        default:
            // This code is for temp not showing the error for Telugu bcoz of not have live tv setUp
                self.sdkError = .other
        }
        playerState = .errorPlayback
        default:
                debugPrint("")
        }
    }

    private func addPlayerAdEventsListener() {
        self.mediaPlayer?.playerIMAadEventPublisher?
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    debugPrint("Oops error \(error)")
                case .finished:
                    debugPrint("event received")
                }
            } receiveValue: { [weak self] result in
                guard self != nil else { return }
                self?.addListenerForPlayerAdEvents(result: result)
            }
            .store(in: &self.observers)
    }

    func addListenerForPlayerEventsContinuation(result: IPlayerEvent) {

    }
    private func addListenerForPlayerAdEvents(result: IPlayerIMAadEvent) {
        debugPrint(result.payloadData.description)
        logAdEvent("\(result.eventType)")
        if "\(result.eventType)" == "IMAadLoaded" {
            playerState = .showingAds
        } else if "\(result.eventType)" == "IMAadContentResume" {
            playerState = .hiddenAds
        }
        if result.payloadData.keys.contains(LogixPlayerSDK.AdEventDataKeys.imaAdMetaData) {
            setAdCuePoints(data: result.payloadData)
        }
    }

    private func logAdEvent(_ message: String) {
        debugPrint("Ad Event:: \(message)")
        switch message {
        case "IMAadProgress":
            isShowingAd = true
        case "IMAadComplete":
            isShowingAd = false
        case "IMAadContentResume":
            isShowingAd = false
        default:
            break
        }
    }

    func setAdCuePoints(data: [AnyHashable: Any]) {
        let iMAAdData = data.values.first(where: { data in
            ((data as? LogixPlayerSDK.IMAAdData) != nil)
        }) as? LogixPlayerSDK.IMAAdData
        if let cuePoints = iMAAdData?.cuePoints as? [Double], !cuePoints.isEmpty {
            adPositions = cuePoints
        } else if let adPodCuePoint = iMAAdData?.adPodCuePoint as? Double {
            adPositions.append(adPodCuePoint)
        }
    }
}
extension PlaybackViewModel {
   /* func getLiveAssetHLS(rssUrl: String) -> Future<String, Error> {
        return Future<String, Error> { promise in
            APIManager.shared.getLiveHLSURL(rssURL: rssUrl)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        promise(.failure(error))
                    }
                }, receiveValue: { hlsURL in
                    return promise(.success(hlsURL))
                })
                .store(in: &self.cancellables)
        }
    }*/
}
