//
//  PlaybackAsset.swift
//  News18AppleTV
//
//  Created by Mohan Sivaram Ramasamy on 05/11/24.
//

import Foundation
import LogixPlayerSDK

struct PlaybackAsset: AnyPlayableAsset {
    var mediaId: String
    var mStartTime: TimeInterval
    var mTimeDuration: TimeInterval
    var category: MediaContentCategory
    var partnerType: MediaPartnerType
    var playableMediaType: PlayableMediaType
    var contentProtectionType: ContentProtectionType
    var mediaName: String?
    var mediaPlayableURL: String?
    var isLocalPlayableContent: Bool
    var downloadItemID: String?
    var fpsCertificateData: Data?
    var imaConfig: IMAConfig?
    var imaDAIConfig: IMADAIConfig?
    var macrosForAds: [String: String]?
    var externalSubtitles: [String: String]?

    init(category: MediaContentCategory,
         partnerType: MediaPartnerType,
         playableMediaType: PlayableMediaType,
         contentProtectionType: ContentProtectionType, imaConfig: IMAConfig?) {
        self.mediaId = "3456789"
        self.mStartTime = 0.0
        self.mTimeDuration = 0.0
        self.category = category
        self.partnerType = partnerType
        self.playableMediaType = playableMediaType
        self.contentProtectionType = contentProtectionType
        self.isLocalPlayableContent = false
        self.imaConfig = imaConfig
    }
}
