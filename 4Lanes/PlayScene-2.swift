//
//  PlayScene.swift
//  4Lanes
//
//  Created by Joey Hoang on 1/3/15.
//  Copyright (c) 2015 XimpleApp. All rights reserved.
//

import SpriteKit
import GameKit
import Social

class PlayScene: SKScene, SKPhysicsContactDelegate {
    var sharedInstance = Singleton.sharedInstance
    var adHelper: AdHelper = AdHelper()
    
    var center: CGPoint!
    
    var carRed: Car!
    var carBlue: Car!
    var carWidth: CGFloat!
    
    var circleShapes = [Shape]()
    
    var shapeMoveSpeed = kShapeMoveSpeed
    
    var currentScoreLabel:Label!
    var failedLabel:Label!
    var helloUser:Label = Label(string: "", color: UIColor.blackColor(), size: kFontSize)
    
    var isHighscore = false
    var gameOver = false
    
    var score = 0
    
    var replayButton:Button!
    var facebookButton:Button!
    var twitterButton:Button!
    var homeButton:Button!
    var highscoreButton:Button!
    
    override func didMoveToView(view: SKView) {
        // setup physics
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
        self.physicsWorld.contactDelegate = self
        
        // center point!
        self.center = CGPointMake(self.size.width/2, self.size.height/2)
        
        // background
        let background = SKSpriteNode(imageNamed: "Background")
        background.position = self.center
        background.zPosition = -1
        self.addChild(background)
        
        // cars
        self.carRed = Car(color: 0)
        // store car width
        self.carWidth = self.carRed.sprite.size.width
        self.carRed.position = CGPointMake(self.center.x - self.carWidth * 3, self.center.y - self.carRed.sprite.size.height * 1.5)
        self.addChild(self.carRed)
        
        self.carBlue = Car(color: 1)
        self.carBlue.position = CGPointMake(self.center.x + self.carWidth * 3, self.center.y - self.carRed.sprite.size.height * 1.5)
        self.addChild(self.carBlue)
        
        // shapes
        self.spawnShape(0)
        self.spawnShape(1)
        
        // score Label
        let fontColor: UIColor = UIColor.blackColor()
        self.currentScoreLabel = Label(string: "0", color: fontColor, size: kFontSize)
        self.currentScoreLabel.fontName = "Arial"
        self.currentScoreLabel.position = CGPointMake(self.size.width/2, self.size.height - kFontSize * 4)
        self.addChild(self.currentScoreLabel)
        
        // ask to rate
        self.sharedInstance.askToRateApp()
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
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
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
            }
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        if !self.gameOver {
            // update score
            self.currentScoreLabel.text = String(self.score)
            
            // if circle passed cars, game is also over
            for circle in self.circleShapes {
                if circle.position.y < self.carRed.position.y - self.carRed.sprite.size.height && circle.body.categoryBitMask == kShapeCircleIdentifier {
                    NSLog("%@", circle.position.y)
                    self.gameOver = true
                    self.gameIsOver()
                }
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (!self.gameOver) {
            if (contact.bodyA.categoryBitMask == kShapeSquareIdentifier || contact.bodyB.categoryBitMask == kShapeSquareIdentifier) {
                // game over
                self.gameOver = true
                self.gameIsOver()
            }
            if (contact.bodyA.categoryBitMask == kShapeCircleIdentifier || contact.bodyB.categoryBitMask == kShapeCircleIdentifier) {
                // game over
                self.score++
                
                // remove circle shape
                var circleShapeBody: SKPhysicsBody!
                if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
                    circleShapeBody = contact.bodyB
                }
                else {
                    circleShapeBody = contact.bodyB
                }
                circleShapeBody.categoryBitMask = kShapeCircleDoneIdentifier
                var circleShape = circleShapeBody.node as SKSpriteNode
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
        overlay.alpha = 0.8
        overlay.position = self.center
        self.addChild(overlay)
        
        // failed label
        self.failedLabel = Label(string: "GAME OVER", color: UIColor.yellowColor(), size: kFontSize*1.5)
        self.failedLabel.position = CGPointMake(self.size.width/2, self.size.height/2 + kFontSize*4)
        self.addChild(self.failedLabel)
        
        // and a replay button. show score, replay, social share
        // NOTE: everything is layout according to replayButton's position :)
        self.replayButton = Button(imageNamed: "playButton")
        self.replayButton.position = CGPointMake(self.size.width/2 - self.replayButton.size.width * kButtonDistance, self.size.height/2 - self.replayButton.size.height)
        self.homeButton = Button(imageNamed: "homeButton")
        self.homeButton.position = CGPointMake(self.size.width/2 + self.replayButton.size.width * kButtonDistance, self.size.height/2 - self.replayButton.size.height)
        
        // social share buttons
        self.facebookButton = Button(imageNamed: "facebook")
        self.facebookButton.position = CGPointMake(self.size.width/2 - self.replayButton.size.width * kButtonDistance, self.size.height/2 - self.replayButton.size.height * 2.5)
        
        self.twitterButton = Button(imageNamed: "twitter")
        self.twitterButton.position = CGPointMake(self.size.width/2 + self.replayButton.size.width * kButtonDistance, self.size.height/2 - self.replayButton.size.height * 2.5)
        
        // score and highscore
        let fontSize: CGFloat = kFontSize
        let fontColor: UIColor = UIColor.blackColor()
        
        let scoreLabel = Label(string: "Score", color: fontColor, size: fontSize)
        let bestLabel = Label(string: "Best", color: fontColor, size: fontSize)
        let scoreText = Label(string: "\(String(self.score))", color: fontColor, size: fontSize*2)
        let bestText = Label(string: "\(String(self.sharedInstance.getData(kHighscoreText)))", color: fontColor, size: fontSize*2)
        
        scoreLabel.position = CGPointMake(self.facebookButton.position.x, self.replayButton.position.y + self.replayButton.size.height + fontSize * 2)
        bestLabel.position = CGPointMake(self.twitterButton.position.x, scoreLabel.position.y)
        scoreText.position = CGPointMake(scoreLabel.position.x, scoreLabel.position.y - fontSize * 2)
        bestText.position = CGPointMake(bestLabel.position.x, scoreText.position.y)
        
        // add button
        self.sharedInstance.addChildFadeIn(self.replayButton, target: self)
        self.sharedInstance.addChildFadeIn(self.homeButton, target: self)
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
        let delay = SKAction.waitForDuration(NSTimeInterval(1.5))
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
            println("report score \(scoreReporter)")
            GKScore.reportScores(scoreArray, {(error : NSError!) -> Void in
                if error != nil {
                    println("error")
                    NSLog(error.localizedDescription)
                }
            })
            
        }
    }
}
