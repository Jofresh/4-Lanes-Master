//
//  PlayScene.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/3/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit
import GameKit
import Social
import AssetsLibrary
import Darwin


class PlayScene: SKScene, SKPhysicsContactDelegate {
    
    var sharedInstance = Singleton.sharedInstance
    var adHelper: AdHelper = AdHelper()
    
    let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var center: CGPoint!
    
    var carRed: Car!
    var carBlue: Car!
    var carWidth: CGFloat!
    
    var circleShapes = [Shape]()
    
    var shapeMoveSpeed = kShapeMoveSpeed
    
    var currentScoreLabel:Label!
    var failedLabel:Label!
    var slackinLabel:Label!
    var helloUser:Label = Label(string: "", color: UIColor.blackColor(), size: kFontSize)
    
    var isHighscore = false
    var gameOver = false
    
    var score = 0
    
    var replayButton:Button!
    var facebookButton:Button!
    var twitterButton:Button!
    var homeButton:Button!
    var highscoresButton:Button!
    
    // Grab the path, make sure to add it to your project!
    var moneySound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("money", ofType: "wav")!)
    var slackinSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("slackin", ofType: "wav")!)
    var moneyAudioPlayer = AVAudioPlayer()
    var slackinAudioPlayer = AVAudioPlayer()
    
    var playingJermaine: Bool!
    var jermaineChallengeObject: PFObject!
    var videoPath : String!
    
    var localVideoUrlString : String!
    var localVideoUrl : NSURL!
    
    let π = M_PI
    
    
    override func didMoveToView(view: SKView) {
        
        view.multipleTouchEnabled = true
        
        if(playingJermaine == true){
            self.writeVideoDataLocally()
        }
        
        // setup physics
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        self.physicsWorld.contactDelegate = self
        
        // center point!
        self.center = CGPointMake(self.size.width/2, self.size.height/2)
        
        // background
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = self.center
        background.zPosition = -100
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
        
        // shapes
        self.spawnShape(0)
        self.spawnShape(1)
        
        if(playingJermaine == true){
            
            
            let boxBackground = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 110.0, height: 160.0))
            boxBackground.position = CGPointMake(self.size.width/2, self.size.height - 100)
            boxBackground.zPosition = 10
            boxBackground.alpha = 1
            print("screen frame = " + String(self.frame))
            print("boxBackground frame = " + String(boxBackground.frame))
            self.addChild(boxBackground)
            
            
            
            appDel.backgroundMusicPlayer?.pause()
            defaults.setBool(true, forKey: "muted")
            
            let videoPlayer = AVPlayer(URL: self.localVideoUrl!)
            videoPlayer.muted = false
                    
            let videoNode = SKVideoNode(AVPlayer: videoPlayer)
                    
            videoNode.size = CGSize(width: 150, height: 100)
            videoNode.position = CGPointMake(self.size.width/2, self.size.height - 100)
            videoNode.zPosition = 10
            videoNode.zRotation = CGFloat(-(π/2))
            videoNode.play()
            self.addChild(videoNode)
            
            print("videoNode frame === " + String(videoNode.frame))
                    
            // score background
            let scoreBackground = SKSpriteNode(imageNamed: "scoreBackground")
            scoreBackground.alpha = 0.6
            scoreBackground.position = CGPointMake(self.size.width/2, self.size.height - 150)
            scoreBackground.zPosition = 10
            scoreBackground.size = CGSizeMake(100.0, 50.0)
            self.addChild(scoreBackground)
                    
            // score Label
            let fontColor: UIColor = UIColor.whiteColor()
            self.currentScoreLabel = Label(string: "0", color: fontColor, size: kFontSize)
            self.currentScoreLabel.fontName = "BebasNeueBold"
            self.currentScoreLabel.horizontalAlignmentMode = .Center
            self.currentScoreLabel.position = CGPointMake(self.size.width/2, self.size.height - 125 - kFontSize)
            self.currentScoreLabel.zPosition = 100
            self.addChild(self.currentScoreLabel)
                    
        }
        else
        {
            // score background
            let scoreBackground = SKSpriteNode(imageNamed: "scoreBackground")
            scoreBackground.alpha = 0.6
            scoreBackground.position = CGPointMake(self.size.width/2, self.size.height - 75)
            scoreBackground.zPosition = 10
            self.addChild(scoreBackground)
            
            // score Label
            let fontColor: UIColor = UIColor.whiteColor()
            self.currentScoreLabel = Label(string: "0", color: fontColor, size: kFontSize)
            self.currentScoreLabel.fontName = "BebasNeueBold"
            self.currentScoreLabel.horizontalAlignmentMode = .Center
            self.currentScoreLabel.position = CGPointMake(self.size.width/2, self.size.height - 50 - kFontSize)
            self.currentScoreLabel.zPosition = 100
            self.addChild(self.currentScoreLabel)
        }
        
        try! moneyAudioPlayer = AVAudioPlayer(contentsOfURL: moneySound)
        try! slackinAudioPlayer = AVAudioPlayer(contentsOfURL: slackinSound)
        moneyAudioPlayer.prepareToPlay()
        slackinAudioPlayer.prepareToPlay()
        
        // ask to rate
        //self.sharedInstance.askToRateApp()
    }
    
    
    
    func writeVideoDataLocally(){
        try! self.jermaineChallengeObject.fetchIfNeeded()
        let videoFile : PFFile = self.jermaineChallengeObject.objectForKey("jermaineVideo") as! PFFile
        let videoParseUrlString : String = videoFile.url!
        let videoParseUrl : NSURL = NSURL(string: videoParseUrlString)!
        let videoData : NSData = NSData(contentsOfURL: videoParseUrl)!
        
        let videoLocalUrlString : String = NSTemporaryDirectory() + "video.mov"
        let videoLocalUrl : NSURL = NSURL(fileURLWithPath: videoLocalUrlString)
        self.localVideoUrlString = videoLocalUrlString
        self.localVideoUrl = videoLocalUrl
        videoData.writeToFile(videoLocalUrlString, atomically: true)
    }
    
    
    
    func spawnShape(color: Int) {
        if self.gameOver {
            return
        }
        
        // create shape
        let randShape = self.sharedInstance.randNum(0, max: 2)
        let randLane = self.sharedInstance.randNum(0, max: 2)
        let shape = Shape(color: color, shape: randShape, lane: randLane)
        if color == 0 {
            if randLane == 0 {
                shape.position = CGPointMake(self.center.x - self.carWidth * 3, self.size.height + shape.sprite.size.height)
            }
            else {
                shape.position = CGPointMake(self.center.x - self.carWidth, self.size.height + shape.sprite.size.height)
            }
        }
        else {
            if randLane == 0 {
                shape.position = CGPointMake(self.center.x + self.carWidth * 3, self.size.height + shape.sprite.size.height)
            }
            else {
                shape.position = CGPointMake(self.center.x + self.carWidth, self.size.height + shape.sprite.size.height)
            }
        }
        self.addChild(shape)
        
        // save circle shapes into array
        if randShape == 0 {
            self.circleShapes.append(shape)
        }
        
        // move shape
        self.shapeMoveSpeed = self.shapeMoveSpeed - kChangeLaneSpeed/4
        if self.shapeMoveSpeed < 1 {
            self.shapeMoveSpeed = 1
        }
        shape.runAction(SKAction.moveTo(CGPointMake(shape.position.x, -shape.sprite.size.height), duration: self.shapeMoveSpeed))
        
        let randSpawnDelay = self.sharedInstance.randNum(1, max: 5)
        let delay = SKAction.waitForDuration(NSTimeInterval(randSpawnDelay))
        let spawn = SKAction.runBlock({ self.spawnShape(color) })
        let delayThenSpawn = SKAction.sequence([delay, spawn])
        self.runAction(delayThenSpawn)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if location.x < self.center.x {
                self.carRed.changeLane()
            }
            else {
                self.carBlue.changeLane()
            }
            
            if (self.gameOver) {
                if self.nodeAtPoint(location) == self.replayButton {
                    var scene = PlayScene(size: self.frame.size)
                    scene.playingJermaine = false
                    self.sharedInstance.presentScene(scene, target: self)
                }
                if self.nodeAtPoint(location) == self.homeButton {
                    var scene = GameScene(size: self.frame.size)
                    self.sharedInstance.presentScene(scene, target: self)
                }
                if self.nodeAtPoint(location) == self.facebookButton {
                    NSNotificationCenter.defaultCenter().postNotificationName("sharingFacebook", object: nil)
                }
                if self.nodeAtPoint(location) == self.twitterButton {
                    NSNotificationCenter.defaultCenter().postNotificationName("sharingTwitter", object: nil)
                }
                if self.nodeAtPoint(location) == self.highscoresButton {
                    NSNotificationCenter.defaultCenter().postNotificationName("showLeaderboard", object: nil)
                }
            }
        }
    }
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        /* Called when a touch begins */
//        
//        for touch: AnyObject in touches {
//            let location = touch.locationInNode(self)
//            if location.x < self.center.x {
//                self.carRed.changeLane()
//            }
//            else {
//                self.carBlue.changeLane()
//            }
//            
//            if (self.gameOver) {
//                if self.nodeAtPoint(location) == self.replayButton {
//                    var scene = PlayScene(size: self.frame.size)
//                    self.sharedInstance.presentScene(scene, target: self)
//                }
//                if self.nodeAtPoint(location) == self.homeButton {
//                    var scene = GameScene(size: self.frame.size)
//                    self.sharedInstance.presentScene(scene, target: self)
//                }
//                if self.nodeAtPoint(location) == self.facebookButton {
//                    NSNotificationCenter.defaultCenter().postNotificationName("sharingFacebook", object: nil)
//                }
//                if self.nodeAtPoint(location) == self.twitterButton {
//                    NSNotificationCenter.defaultCenter().postNotificationName("sharingTwitter", object: nil)
//                }
//                if self.nodeAtPoint(location) == self.highscoresButton {
//                    NSNotificationCenter.defaultCenter().postNotificationName("showLeaderboard", object: nil)
//                }
//            }
//        }
//    }
    
    override func update(currentTime: CFTimeInterval) {
        if !self.gameOver {
            // update score
            self.currentScoreLabel.text = String(self.score)
            
            // if circle passed cars, game is also over
            for circle in self.circleShapes {
                if circle.position.y < self.carRed.position.y - self.carRed.sprite.size.height && circle.body.categoryBitMask == kShapeCircleIdentifier {
                    self.gameOver = true
                    self.gameIsOver()
                }
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (!self.gameOver) {
            if (contact.bodyA.categoryBitMask == kShapeSquareIdentifier || contact.bodyB.categoryBitMask == kShapeSquareIdentifier) {
                // play slackin sound
                var muted = defaults.boolForKey("muted")
                if (muted == false) {
                    slackinAudioPlayer.play()
                }
                // game over
                self.gameOver = true
                self.gameIsOver()
            }
            if (contact.bodyA.categoryBitMask == kShapeCircleIdentifier || contact.bodyB.categoryBitMask == kShapeCircleIdentifier) {
                // game over
                self.score++
                
                // play money sound
                var muted = defaults.boolForKey("muted")
                if (muted == false) {
                    moneyAudioPlayer.play()
                }
                
                // remove circle shape
                var circleShapeBody: SKPhysicsBody!
                if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
                    circleShapeBody = contact.bodyB
                }
                else {
                    circleShapeBody = contact.bodyB
                }
                circleShapeBody.categoryBitMask = kShapeCircleDoneIdentifier
                var circleShape = circleShapeBody.node as! SKSpriteNode
                circleShape.removeFromParent()
            }
        }
    }
    
    func gameIsOver() {
        // remove cars
        self.carRed.removeFromParent()
        self.carBlue.removeFromParent()

        // clear labels
        self.currentScoreLabel.text = String(" ")
        self.helloUser.text = String(" ")
        
        // add an overlay image
        let overlay = SKSpriteNode(imageNamed: "BackgroundMain")
        overlay.alpha = 1.0
        overlay.position = self.center
        overlay.zPosition = 100
        self.addChild(overlay)
        
        
        
        
        
        // and a replay button. show score, replay, social share
        // NOTE: everything is layout according to replayButton's position :)
        self.replayButton = Button(imageNamed: "playButton")
        self.replayButton.position = CGPointMake(self.size.width/2 - 125, self.size.height/2 - self.replayButton.size.height)
        self.replayButton.zPosition = 101
        
        self.homeButton = Button(imageNamed: "homeButton")
//        self.homeButton.position = CGPointMake(self.size.width/2.325 + self.replayButton.size.width * kButtonDistance, self.size.height/2 - self.replayButton.size.height)
        self.homeButton.position = CGPointMake(self.size.width/2, self.size.height/2 - self.replayButton.size.height)
        self.homeButton.zPosition = 101
        
        self.highscoresButton = Button(imageNamed: "highscoresButton")
        self.highscoresButton.position = CGPointMake(self.size.width/2 + 125, self.size.height/2 - self.replayButton.size.height)
        self.highscoresButton.zPosition = 101
        
        // social share buttons
        self.facebookButton = Button(imageNamed: "facebook")
        self.facebookButton.position = CGPointMake(self.size.width/2 - self.replayButton.size.width * kButtonDistance, self.size.height/2 - self.replayButton.size.height * 2.5)
        self.facebookButton.zPosition = 101
        
        self.twitterButton = Button(imageNamed: "twitter")
        self.twitterButton.position = CGPointMake(self.size.width/2 + self.replayButton.size.width * kButtonDistance, self.size.height/2 - self.replayButton.size.height * 2.5)
        self.twitterButton.zPosition = 101
        
        // score and highscore
        let fontSize: CGFloat = kFontSize
        let fontColor: UIColor = UIColor.whiteColor()
        
        
        var scoreLabel: Label
        var bestLabel: Label
        var scoreText: Label
        var bestText: Label
        
        if(self.playingJermaine == true)
        {
            self.appDel.backgroundMusicPlayer?.play()
            self.defaults.setBool(false, forKey: "muted")
            var jermaineScoreString: String? = self.jermaineChallengeObject.objectForKey("jermaineScore") as! String?
            var jermaineScore: Int? =  Int(jermaineScoreString!)
            if(jermaineScore > self.score)
            {
                // failed label
                self.failedLabel = Label(string: "JD BEAT YOU", color: UIColor.whiteColor(), size: kFontSize*1.5)
                self.failedLabel.fontName = "BebasNeueBold"
                self.failedLabel.position = CGPointMake(self.size.width/2, self.size.height/2 + kFontSize*5)
                self.failedLabel.zPosition = 101
                self.addChild(self.failedLabel)
                
                self.slackinLabel = Label(string: "SLACKIN' ON YOUR PIMPIN'", color: UIColor.whiteColor(), size: kFontSize*1)
                self.slackinLabel.fontName = "BebasNeueBold"
                self.slackinLabel.position = CGPointMake(self.size.width/2, self.size.height/2 + kFontSize*4)
                self.slackinLabel.zPosition = 101
                self.addChild(self.slackinLabel)
            }
            else
            {
                // failed label
                self.failedLabel = Label(string: "YOU BEAT JD", color: UIColor.whiteColor(), size: kFontSize*1.5)
                self.failedLabel.fontName = "BebasNeueBold"
                self.failedLabel.position = CGPointMake(self.size.width/2, self.size.height/2 + kFontSize*5)
                self.failedLabel.zPosition = 101
                self.addChild(self.failedLabel)
                
                self.slackinLabel = Label(string: "STAY UP PIMPIN!'", color: UIColor.whiteColor(), size: kFontSize*1)
                self.slackinLabel.fontName = "BebasNeueBold"
                self.slackinLabel.position = CGPointMake(self.size.width/2, self.size.height/2 + kFontSize*4)
                self.slackinLabel.zPosition = 101
                self.addChild(self.slackinLabel)
            }
            
            scoreLabel = Label(string: "YOUR SCORE", color: fontColor, size: fontSize)
            bestLabel = Label(string: "JD's SCORE", color: fontColor, size: fontSize)
            scoreText = Label(string: "\(String(self.score))", color: fontColor, size: fontSize*2)
            bestText = Label(string: jermaineScoreString!, color: fontColor, size: fontSize*2)
            
            scoreLabel.position = CGPointMake(self.facebookButton.position.x - 25, self.replayButton.position.y + self.replayButton.size.height + fontSize * 2)
            bestLabel.position = CGPointMake(self.twitterButton.position.x + 25, scoreLabel.position.y)
            scoreText.position = CGPointMake(scoreLabel.position.x, scoreLabel.position.y - fontSize * 2)
            bestText.position = CGPointMake(bestLabel.position.x, scoreText.position.y)
            
            self.updateChallengeObject()
            self.saveVideoPresentAlert()
            
        }
        else
        {
            // failed label
            self.failedLabel = Label(string: "GAME OVER", color: UIColor.whiteColor(), size: kFontSize*1.5)
            self.failedLabel.fontName = "BebasNeueBold"
            self.failedLabel.position = CGPointMake(self.size.width/2, self.size.height/2 + kFontSize*5)
            self.failedLabel.zPosition = 101
            self.addChild(self.failedLabel)
            
            self.slackinLabel = Label(string: "SLACKIN' ON YOUR PIMPIN'", color: UIColor.whiteColor(), size: kFontSize*1)
            self.slackinLabel.fontName = "BebasNeueBold"
            self.slackinLabel.position = CGPointMake(self.size.width/2, self.size.height/2 + kFontSize*4)
            self.slackinLabel.zPosition = 101
            self.addChild(self.slackinLabel)
            scoreLabel = Label(string: "Score", color: fontColor, size: fontSize)
            bestLabel = Label(string: "Best", color: fontColor, size: fontSize)
            scoreText = Label(string: "\(String(self.score))", color: fontColor, size: fontSize*2)
            bestText = Label(string: "\(String(self.sharedInstance.getData(kHighscoreText)))", color: fontColor, size: fontSize*2)
            
            scoreLabel.position = CGPointMake(self.facebookButton.position.x, self.replayButton.position.y + self.replayButton.size.height + fontSize * 2)
            bestLabel.position = CGPointMake(self.twitterButton.position.x, scoreLabel.position.y)
            scoreText.position = CGPointMake(scoreLabel.position.x, scoreLabel.position.y - fontSize * 2)
            bestText.position = CGPointMake(bestLabel.position.x, scoreText.position.y)
        }
        
        scoreLabel.fontName = "BebasNeueBold"
        bestLabel.fontName = "BebasNeueBold"
        scoreText.fontName = "BebasNeueBold"
        bestText.fontName = "BebasNeueBold"
        
        scoreLabel.zPosition = 101
        scoreText.zPosition = 101
        bestLabel.zPosition = 101
        bestText.zPosition = 101
        
        // add button
        self.sharedInstance.addChildFadeIn(self.replayButton, target: self)
        self.sharedInstance.addChildFadeIn(self.homeButton, target: self)
        self.sharedInstance.addChildFadeIn(self.highscoresButton, target: self)
        self.sharedInstance.addChildFadeIn(self.facebookButton, target: self)
        self.sharedInstance.addChildFadeIn(self.twitterButton, target: self)
        
        self.sharedInstance.addChildFadeIn(scoreLabel, target: self)
        self.sharedInstance.addChildFadeIn(bestLabel, target: self)
        self.sharedInstance.addChildFadeIn(scoreText, target: self)
        self.sharedInstance.addChildFadeIn(bestText, target: self)
        
        // report score
        self.reportScore(self.score, leaderboard: kLeaderBoardID)
        
        // SHOW INTERSTITIAL ADS, Show ads after a few seconds
        // show Admob or OTHER Interstitial
        NSNotificationCenter.defaultCenter().postNotificationName("presentAdmobInterstitial", object: nil)
        let delay = SKAction.waitForDuration(NSTimeInterval(0.5))
        let adBlock = SKAction.runBlock({
            self.adHelper.presentInterstital(self.sharedInstance.viewController!)
        })
        let delayThenShowAd = SKAction.sequence([delay, adBlock])
        self.runAction(delayThenShowAd)
    }
    
    func reportScore(score: Int, leaderboard: String) {
        // save current score
        self.sharedInstance.score = score
        
        // check if we got highscore
        let currentHighScore = self.sharedInstance.getData(kHighscoreText)
        if (self.score > currentHighScore) {
            self.sharedInstance.saveData(score, key: kHighscoreText)
            self.isHighscore = true
            self.failedLabel.text = "HIGHSCORE"
        }
        
        if GKLocalPlayer.localPlayer().authenticated {
            var scoreReporter = GKScore(leaderboardIdentifier: leaderboard)
            scoreReporter.value = Int64(score)
            var scoreArray: [GKScore] = [scoreReporter]
            print("report score \(scoreReporter)")
            
            GKScore.reportScores(scoreArray, withCompletionHandler: nil)
//            GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
//                if error != nil {
//                    println("error")
//                    NSLog(error.localizedDescription)
//                }
//            })
            
        }
    }
    
    
    func updateChallengeObject(){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            try! self.jermaineChallengeObject.fetchIfNeeded()
            self.jermaineChallengeObject.setObject(true, forKey: "userCompleted")
            let scoreString = String(self.score)
            self.jermaineChallengeObject.setObject(scoreString, forKey: "userScore")
            try! self.jermaineChallengeObject.save()
        })
    }
    
    func saveVideoPresentAlert(){
        let alert = UIAlertController(title: "We will save Jermaine's video to your photos", message: "", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default) { action -> Void in
            print("saving video located at " + self.localVideoUrlString)
            print("\n")
            
            if(UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.localVideoUrlString)){
                print("possible to save file")
                UISaveVideoAtPathToSavedPhotosAlbum(self.localVideoUrlString, self, "video:didFinishSavingWithError:contextInfo:", nil)
            }
            
            else{
                print("file cannot be saved")
            }
            
            
            
        })
        self.sharedInstance.viewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func video(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: UnsafeMutablePointer<Void>) {
        print("Saved video with error --- " + error.localizedDescription)
    }
}
