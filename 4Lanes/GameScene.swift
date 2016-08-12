//
//  GameScene.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit
import GameKit

class GameScene: SKScene {
    
    var sharedInstance = Singleton.sharedInstance
    
    // Get the AppDelegate
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var center: CGPoint!
    
    var carRed: Car!
    var carBlue: Car!
    var carWidth: CGFloat!
    
    var jermaineChallenegeReady: Bool!
    var waitingForJermaine: Bool!
    
    let playButton = Button(imageNamed:"playButton")
    var musicButton = Button(imageNamed:"musicButton")
    let alertButton = Button(imageNamed:"alertButton")
    let highscoresButton = Button(imageNamed:"highscoresButton")
    let moreGamesButton = Button(imageNamed: "moreGamesButton")
    
    //need playJermaine image
    var playJermaineButton = Button(imageNamed: "PlayJDButton")
    var jermaineChallengeObject: PFObject!
    
    override func didMoveToView(view: SKView) {
        // center point!
        self.center = CGPointMake(self.size.width/2, self.size.height/2)
        
        // background
        let background = SKSpriteNode(imageNamed: "BackgroundMain")
        background.zPosition = -1
        background.position = self.center
        self.addChild(background)
        
        // cars
        self.carRed = Car(color: 0)
        // store car width
        self.carWidth = self.carRed.sprite.size.width
        self.carRed.position = CGPointMake(self.center.x - self.carWidth * 3, self.center.y - self.carRed.sprite.size.height * 2.5)
        self.addChild(self.carRed)
        
        self.carBlue = Car(color: 1)
        self.carBlue.position = CGPointMake(self.center.x + self.carWidth * 3, self.center.y - self.carRed.sprite.size.height * 2.5)
        self.addChild(self.carBlue)
        
        // buttons
        let displacement:CGFloat = -self.carRed.sprite.size.height

        playButton.position = CGPointMake(self.size.width/2, self.size.height/1.5 - playButton.size.height * 2.5 - displacement)
        self.sharedInstance.addChildFadeIn(playButton, target: self)
        
        var muted = defaults.boolForKey("muted")
        if (muted == true) {
            musicButton = Button(imageNamed: "musicMuteButton")
        }
        else {
            musicButton = Button(imageNamed: "musicButton")
        }
        musicButton.position = CGPointMake(self.size.width/2, self.size.height/2 - playButton.size.height*1.15)
        self.sharedInstance.addChildFadeIn(self.musicButton, target: self)
        
        //check for challenege method will see if the user has an active game and set the button image appropriately
        checkForChallenge()
  
        let title = SKSpriteNode(imageNamed: "Logo")
        title.position = CGPointMake(self.center.x, self.center.y*1.5)
        self.addChild(title)
        

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if self.nodeAtPoint(location) == self.playButton {
                var scene = PlayScene(size: self.frame.size)
                scene.playingJermaine = false
                self.sharedInstance.presentScene(scene, target: self)
            }
            if self.nodeAtPoint(location) == self.moreGamesButton {
                UIApplication.sharedApplication().openURL(NSURL(string: kDeveloperLink)!)
            }
            if self.nodeAtPoint(location) == self.highscoresButton {
                NSNotificationCenter.defaultCenter().postNotificationName("showLeaderboard", object: nil)
            }
            if self.nodeAtPoint(location) == self.musicButton {
                if (appDel.backgroundMusicPlayer?.playing() == true){
                    appDel.backgroundMusicPlayer?.pause()
                    defaults.setBool(true, forKey: "muted")
                    self.sharedInstance.removeChildFadeOut(self.musicButton, duration: 0)
                    self.musicButton = Button(imageNamed: "musicMuteButton")
                    musicButton.position = CGPointMake(self.size.width/2, self.size.height/2 - playButton.size.height*1.25)
                    self.sharedInstance.addChildFadeIn(self.musicButton, target: self)
                }
                else{
                    appDel.backgroundMusicPlayer?.play()
                    defaults.setBool(false, forKey: "muted")
                    self.sharedInstance.removeChildFadeOut(self.musicButton, duration: 0)
                    self.musicButton = Button(imageNamed: "musicButton")
                    musicButton.position = CGPointMake(self.size.width/2, self.size.height/2 - playButton.size.height*1.25)
                    self.sharedInstance.addChildFadeIn(self.musicButton, target: self)
                }
            }
            if self.nodeAtPoint(location) == self.playJermaineButton {
                if(self.waitingForJermaine == true){
                    let alert = UIAlertController(title: "Waiting for Jermaine!", message: "We'll let you know when JD plays you back", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.sharedInstance.viewController!.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    if(self.jermaineChallenegeReady == true){
                        var scene = PlayScene(size: self.frame.size)
                        scene.playingJermaine = true
                        scene.jermaineChallengeObject = self.jermaineChallengeObject
                        self.sharedInstance.presentScene(scene, target: self)
                    }
                    
                    else{
                        self.playJermaineButton.userInteractionEnabled = false
                        self.sharedInstance.getIAPInfo()
                    }
                }
            }
        }
    }
    
    func checkForChallenge() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let query = PFQuery(className: "Challenge")
            let uuid = UIDevice.currentDevice().identifierForVendor!.UUIDString
            query.whereKey("pushChannel", equalTo: uuid)
            query.whereKey("userCompleted", equalTo: false)
            let queryArray = try! query.findObjects()
            dispatch_async(dispatch_get_main_queue(), {
                if queryArray.count > 0
                {
                    let challengeObject = queryArray.first
                    let jermaineCompeleted = challengeObject!.objectForKey("jermaineCompleted") as! Bool
                    if jermaineCompeleted{
                        //set playJermaineButton image to start challenege
                        self.jermaineChallengeObject = challengeObject
                        
                        self.jermaineChallenegeReady = true
                        self.waitingForJermaine = false
                        self.playJermaineButton = Button(imageNamed: "StartJDButton")
                    }
                    else{
                        //set playJermaineButton image to waiting on jermaine
                        self.jermaineChallenegeReady = false
                        self.waitingForJermaine = true
                        self.playJermaineButton = Button(imageNamed: "WaitingJDButton")
                    }
                }
                else{
                    self.jermaineChallenegeReady = false
                    self.waitingForJermaine = false
                    self.playJermaineButton = Button(imageNamed: "PlayJDButton")
                    //set playJermaineButton image to play jermaine
                }
                self.playJermaineButton.position = CGPointMake(self.size.width/2, self.musicButton.position.y - 150)
                self.playJermaineButton.size = CGSizeMake(200.0, 200.0)
                self.sharedInstance.addChildFadeIn(self.playJermaineButton, target: self)
            })
        })
    }
    
    func setJermaineButton(buttonName : String){
        self.playJermaineButton.removeFromParent()
        self.playJermaineButton = Button(imageNamed: buttonName)
        self.playJermaineButton.position = CGPointMake(self.size.width/2, self.musicButton.position.y - 150)
        self.playJermaineButton.size = CGSizeMake(200.0, 200.0)
        self.sharedInstance.addChildFadeIn(self.playJermaineButton, target: self)
        self.playJermaineButton.userInteractionEnabled = true
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
