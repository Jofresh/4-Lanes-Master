//
//  AdHelper.swift
//  FallingBalls
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit
import iAd

class AdHelper: SKNode {
    var iAdView:ADBannerView!
    var bannerView: GADBannerView!
    var interstitial: GADInterstitial!
    
    override init() {
        super.init()
    }
    
    // choosing approritate banner to show :)
    func showBanner(target: GameViewController) {
        if kUseiAd == 1 && kUseAdmob == 1 {
            let rand = Int(arc4random_uniform(UInt32(2))) // generate a random number between 0 and n-1
            if rand == 1 {
                self.AdmobBanner(target)
            }
            else {
                self.iAdBanner(target)
            }
        }
        else if kUseiAd == 1 && kUseAdmob == 0 {
            self.iAdBanner(target)
        }
        else if kUseiAd == 0 && kUseAdmob == 1 {
            self.AdmobBanner(target)
        }
        else {
            // no banner ads will be shown
        }
    }
    
    func AdmobBanner(target: GameViewController) {
        var adHeight: CGFloat = 50.0
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            adHeight = 90.0
        }
        self.bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: CGPointMake(CGRectGetMinX(target.view.frame), CGRectGetMaxY(target.view.frame) - adHeight))
        
        self.bannerView.adUnitID = kAdmobBanner
        self.bannerView.delegate = target
        self.bannerView.rootViewController = target
        target.view.addSubview(self.bannerView)
        self.bannerView.loadRequest(GADRequest())
    }
    
    func iAdBanner(target: GameViewController) {
        self.iAdView = ADBannerView(adType: ADAdType.Banner)
        self.iAdView.frame = CGRectMake(0, target.view.frame.size.height, iAdView.frame.width, iAdView.frame.height)
        self.iAdView.delegate = target
        target.view.addSubview(self.iAdView)
    }
    
    func AdmobInterstitial(target: GameViewController) {
        self.interstitial = GADInterstitial()
        self.interstitial.delegate = target
        self.interstitial.adUnitID = kAdmobInterstitial
        self.interstitial.loadRequest(GADRequest())
    }
    
    // admob interstitial
    func presentAdmobInterstitial(target: GameViewController) {
        let rand = Int(arc4random_uniform(UInt32(kInterstitialAdFrequencies))) // generate a random number between 0 and n-1
        if rand == 0 {
            if kUseAdmob == 1 {
                if let isReady = self.interstitial?.isReady {
                    self.interstitial.presentFromRootViewController(target)
                }
            }
        }
    }
    
    // other (chartboost, revmob, vungle) interstitals
    func presentInterstital(target: GameViewController) {
        let rand = Int(arc4random_uniform(UInt32(kInterstitialAdFrequencies))) // generate a random number between 0 and n-1
        if rand == 0 {
            if kUseChartboost == 1 {
                Chartboost.showInterstitial(CBLocationHomeScreen)
            }
            if kUseRevmob == 1 {
                RevMobAds.session().showFullscreen();
            }
            if kUseVungle == 1 {
                VungleSDK.sharedSDK().playAd(target)
               // VungleSDK.sharedSDK().playAd(target, error: nil)
            }
        }
    }
    
    // Required so XCode doesn't throw warnings
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
