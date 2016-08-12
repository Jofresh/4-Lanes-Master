//
//  Singleton.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import SpriteKit
import StoreKit
import Parse
import Bolts

class Singleton{
    var score = 0
    
    var facebookUserName: String?
    var viewController: GameViewController?
    
    var challengeObjects : Array<AnyObject!>!
    
    class var sharedInstance : Singleton {
        struct Static {
            static let instance : Singleton = Singleton()
        }
        return Static.instance
    }
    
    // addChild with fadeIn effect, removeChild with FadeOut effect
    func addChildFadeIn(node: SKNode, target: SKNode) {
        node.alpha = 0
        target.addChild(node)
        node.runAction(SKAction.fadeAlphaTo(1.0, duration: NSTimeInterval(kAddChildSpeed)))
    }
    func removeChildFadeOut(node: SKNode, duration: CGFloat) {
        let fadeOut = SKAction.fadeAlphaTo(0.0, duration: NSTimeInterval(duration))
        let block = SKAction.runBlock({ node.removeFromParent()})
        node.runAction(SKAction.sequence([fadeOut, block]))
    }
    
    // present scene
    func presentScene(scene: SKScene, target: SKScene) {
        let skView = target.view as SKView!
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene, transition: SKTransition.crossFadeWithDuration(kSceneTransitionSpeed))
    }
    
    // ask to rate our app
    func askToRateApp() {
        var numPlay = self.getData(kNumPlayText)
        let remainder = numPlay % kNumPlayToAskForRating
        if numPlay > 0 && remainder == 0 {
            NSLog("play: %d", numPlay)
            var refreshAlert = UIAlertController(title: "Rate \(kGameName)", message: "Thank you for playing. Please rate this game. It will only take 10 seconds. Promise!", preferredStyle: UIAlertControllerStyle.Alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                let openUrl = UIApplication.sharedApplication().openURL(NSURL(string: "https://itunes.apple.com/us/app/top-app/id\(kGameID)")!)
            }))
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
                NSLog("next time ask again")
            }))
            if let view = self.viewController {
                view.presentViewController(refreshAlert, animated: true, completion: nil)
            }
        }
        numPlay++
        self.saveData(numPlay, key: kNumPlayText)
    }
    
    // choosing approritate interstitial to show :)
    // if both are 1, pick at random. if not, 0 is Chartboost, 1 is Admob
    func whichInterstitial() -> Int {
        if kUseChartboost == 1 && kUseAdmob == 1 {
            let rand = Int(arc4random_uniform(UInt32(2))) // generate a random number between 0 and n-1
            return rand;
        }
        else if kUseChartboost == 1 && kUseAdmob == 0 {
            return 0
        }
        else if kUseChartboost == 0 && kUseAdmob == 1 {
            return 1
        }
        return 2
    }
    
    // generating a random number INCLUDING min and max
    func randNum(min: Int, max: Int) -> Int {
        let rand = Int(arc4random_uniform(UInt32(max)))
        return rand + min
    }
    
    // we're saving our data as String, make it easier to make a function
    func saveData(data: Int, key: String) {
        var userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(String(data), forKey: key)
        userDefaults.synchronize()
    }
    
    func getData(key: String) -> Int {
        var number: Int = 0
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if let object = userDefaults.valueForKey(key) as? String {
            //number = object.toInt()!
            number = Int(object)!
        }
        return number
    }
    
    func getIAPInfo(){
        self.viewController?.requestProductData()
    }
    
    func checkForChallenge(){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let query = PFQuery(className: "Challenge")
            
            query.whereKey("jermaineCompleted", equalTo: true)
            
            try! self.challengeObjects = query.findObjects()
            
            
            
        })
        
    }
    
    
    
    
    
    
    
}
