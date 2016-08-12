//
//  Constants.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit

let kGameName: String = "4 Lanes"
let kGameID: String = "961122685"                        // For social sharing
let kDeveloperLink: String = "https://itunes.apple.com/us/artist/that-level/id985759226"

//Parse info
let kParseApplicationId : String = "5BCFypDofYnB9u44rumo513XXJ5ZeT4s9F6tYmUB"
let kParseClientKey : String = "qV26VqVMFAtwySY56yiFwKBMO8rVP3FeIeiEyG7m"

// Leaderboards
let kLeaderBoardID: String = "1"
let kRushModeLeaderBoardID: String = ""

// This game supports iAd, Revmob, Chartboost, Vungle, and Admob ads
// if you don't want to show any particular ad, then change its value to 0 instead of 1
// anything set to 1 will be shown. Showing more than one ads at a time will DEFINITELY annoy users
// by default, all 0 meaning no ads will be shown
// Banner: Admob vs iOS
// Interstitial Admob, Chartboost, Vungle, and Revmob
let kUseiAd = 0
let kUseAdmob = 0
let kUseChartboost = 1

let kUseRevmob = 0
let kUseVungle = 0

// PUT IN YOUR APPRIPRIATE APP ID FOR ADS NETWORK THAT YOU'RE USING
let kAdmobBanner: String = " "                   // Your Admob Banner
let kAdmobInterstitial: String = " "             // Your Admob Interstitial

let kChartboostAppID: String = "5510318a0d60256c91fcbd07"               // Your Chartboost App ID
let kChartboostAppSignature: String = "7a5e91ba695410c91690483cdc444c72e436697c"        // Your Chartboost App Signature

let kRevmobAppID: String = " "                   // Your Revmob App ID

let kVungleAppID: String = " "                   // Your Vungle App ID

// Interstitial showing frequencies = chance of showing ads
// 1 = show every time they lose, 2 = show every other time they lose, 3 = show 1/3 of the time they lose
// and so on...
let kInterstitialAdFrequencies = 3

// Game Settings, only changes below if you know what you're doing
let kNumTilesPerRow: Int = 4
let kNumRowsPerScene: Int = 4

let kSceneTransitionSpeed = 1.0
let kButtonFadingSpeed = 0.2
let kAddChildSpeed: CGFloat = 1.0
let kSpawnSpeed: CGFloat = 0.5
let kChangeLaneSpeed = 0.1
let kShapeMoveSpeed = 2.0

let kCarRotateAngle = 30.0

let kButtonDistance: CGFloat = 0.75
let kFontSize: CGFloat = 40.0
let kHighscoreText = "highscore"
let kHighscoreHardModeText = "highscoreHardMode"
let kNumPlayText = "numPlay"
let kNumPlayToAskForRating = 10
let kNumPlayToAskForFacebookLogin = 13

let kCarIdentifier: UInt32 = 1 << 0
let kShapeSquareIdentifier: UInt32 = 1 << 1
let kShapeCircleIdentifier: UInt32 = 1 << 2
let kShapeCircleDoneIdentifier: UInt32 = 1 << 3

