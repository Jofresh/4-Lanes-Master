//
//  BackgroundMusicPlayer.swift
//  4Lanes
//
//  Created by Sean Hubbard on 3/26/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import Foundation

class BackgroundMusicPlayer: NSObject, AVAudioPlayerDelegate {
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()
    var backgroundMusicPlayer = AVAudioPlayer()
    let backgroundMusic = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("background", ofType: "mp3")!)
    
    override init() {
        super.init()
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
       // AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        try! AVAudioSession.sharedInstance().setActive(true)
       // AVAudioSession.sharedInstance().setActive(true, error: nil)
        var error:NSError?
        try! backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusic)
       // backgroundMusicPlayer = AVAudioPlayer(contentsOfURL: backgroundMusic, error: &error)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
    }
    
    func play() {
        backgroundMusicPlayer.play()
    }
    
    func stop() {
        backgroundMusicPlayer.stop()
    }
    
    func pause() {
        backgroundMusicPlayer.pause()
    }
    
    func toggle() {
        if (playing() == true) {
            self.pause()
        } else {
            self.play()
        }
    }
    
    func playing() -> Bool
    {
        return backgroundMusicPlayer.playing
    }
    
}