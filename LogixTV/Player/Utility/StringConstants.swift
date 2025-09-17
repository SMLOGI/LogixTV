//
//  StringConstants.swift
//  VideoPlayerSwiftUI
//
//  Created by Pradeep  Vijay Deore on 09/07/25.
//

import Foundation

class StringConstants {
    
/***
 Sample ad tags:
 https://developers.google.com/interactive-media-ads/docs/sdks/ios/client-side/tags#main-content
 
 Sample DAi ad keys:
 https://developers.google.com/ad-manager/dynamic-ad-insertion/streams
 */
    
    /// playback url
    static let mp4Url = "https://storage.googleapis.com/gvabox/media/samples/stock.mp4"
    
    static let sampleHlsUrl = "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
    
    /// ad urls
    static let onlyPreproll = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpreonly&ciu_szs=300x250%2C728x90&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&correlator="
    
    static let prerollAndBumper = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpreonlybumper&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&correlator="
    
    static let preMidPostRoll = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpost&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator="
    
    static let multiMidRoll = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpostlongpod&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator="
    
    static let daiStreamURL = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_preroll_skippable&sz=640x480&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator="
    
    /// live urls
    static let daiKey1 = "c-rArva4ShKVIAkNfy6HUQ"
}
