//
//  GameViewController.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit
import Social
import iAd

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            let sceneData = try! NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            //var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)
            let archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate, GADInterstitialDelegate, ADBannerViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    var sharedInstance = Singleton.sharedInstance
    var adHelper: AdHelper = AdHelper()
    
    var product: SKProduct?
    var productsArray: Array<SKProduct!> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            // store controller in singleton
            // this is not MVC but I can't think of another way. Sorry ;)
            self.sharedInstance.viewController = self
            
            // load admob
            self.adHelper.showBanner(self)
            if kUseAdmob == 1 {
                self.adHelper.AdmobInterstitial(self)
            }
            
            // game center authentication
            authenticateLocalPlayer()
            
            // subscribe to notification for social sharing and other stuffs
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "sharingFacebook:", name: "sharingFacebook", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "sharingTwitter:", name: "sharingTwitter", object: nil)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentAdmobInterstitial:", name: "presentAdmobInterstitial", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeFacebookButton:", name: "removeFacebookButton", object: nil)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "showLeaderboard:", name: "showLeaderboard", object: nil)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationEnteredForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.AllButUpsideDown
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
//    override func supportedInterfaceOrientations() -> Int {
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
//        } else {
//            return Int(UIInterfaceOrientationMask.All.rawValue)
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // ===================================================================== ADMOB INTERSTITIAL
    func presentAdmobInterstitial(notification: NSNotification) {
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("callAdmobAfter"), userInfo: nil, repeats: false)
    }
    
    func callAdmobAfter() {
        self.adHelper.presentAdmobInterstitial(self)
    }
    
    func interstitialWillDismissScreen(ad: GADInterstitial!) {
        // reload intertitial after dismissed
        self.adHelper.AdmobInterstitial(self)
    }
    // ===================================================================== SOCIAL SHARING
    func sharingFacebook(notification: NSNotification) {
        let shareToFacebook: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        shareToFacebook.setInitialText("I just scored \(self.sharedInstance.score) points in \(kGameName). Can you beat me?")
        shareToFacebook.addURL(NSURL(string: "https://itunes.apple.com/us/app/top-app/id\(kGameID)"))
        shareToFacebook.addImage(UIImage(named: "SharedImage"))
        self.presentViewController(shareToFacebook, animated: true, completion: nil)
    }
    
    func sharingTwitter(notification: NSNotification) {
        let shareToTwitter: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        shareToTwitter.setInitialText("I just scored \(self.sharedInstance.score) points in \(kGameName). Can you beat me?")
        shareToTwitter.addURL(NSURL(string: "https://itunes.apple.com/us/app/top-app/id\(kGameID)"))
        shareToTwitter.addImage(UIImage(named: "SharedImage"))
        self.presentViewController(shareToTwitter, animated: true, completion: nil)
        
    }
    
    // ===================================================================== GAME CENTER
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler = { (viewController, error) -> Void in
            if ((viewController) != nil) {
                self.presentViewController(viewController!, animated: true, completion: nil)
            }
            else {
                print("(GameCenter) Player authenticated: \(GKLocalPlayer.localPlayer().authenticated)")
            }
        }
        
    }
    
    func showLeaderboard(notification: NSNotification) {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        gcViewController.leaderboardIdentifier = kLeaderBoardID
        
        self.presentViewController(gcViewController, animated: true, completion: nil)
    }
    
    func showLeaderboardHardMode(notification: NSNotification) {
        let gcViewController: GKGameCenterViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        
        gcViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        gcViewController.leaderboardIdentifier = kRushModeLeaderBoardID
        
        self.presentViewController(gcViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func requestProductData(){
        if SKPaymentQueue.canMakePayments() {
            print("canMakePayments()")
            let productIdentifiers = NSSet(objects: "com.thatlevel.4lanes.challengejermaine")
            let request = SKProductsRequest(productIdentifiers:
                productIdentifiers as! Set<String>);
            request.delegate = self
            request.start()
        } else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                
                let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
                if url != nil {
                    UIApplication.sharedApplication().openURL(url!)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        var products = response.products
        if (products.count != 0){
            print("products.count > 0")
            for var i = 0; i < products.count; i++ {
                self.product = products[i] as SKProduct
                self.productsArray.append(product!)
                buyProduct()
            }
        }
        if(response.invalidProductIdentifiers.count != 0){
            print("invalid product indentifier --- "+response.invalidProductIdentifiers[0])
        }
    }
    
    func buyProduct(){
        let payment = SKPayment(product: productsArray[0])
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions as [SKPaymentTransaction] {
            
            switch transaction.transactionState {
                
                case SKPaymentTransactionState.Purchased:
                    print("Transaction Approved")
                    print("Product Identifier: \(transaction.payment.productIdentifier)")
                    self.deliverProduct(transaction)
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
                case SKPaymentTransactionState.Failed:
                    print("Transaction Failed")
                    print(transaction.error)
                    let alert = UIAlertController(title: "Transaction Failed", message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                        alert.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
                default:
                    break
            }
        }
    }
    
    func deliverProduct(transaction:SKPaymentTransaction) {
        
        let nameAlert : UIAlertController = UIAlertController(title: "Enter your name so Jermaine can give you a shoutout", message: "", preferredStyle: .Alert)
        
        nameAlert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "name"
        }
        
        let defaultAction : UIAlertAction = UIAlertAction(title: "Ok", style: .Default, handler: { alertAction in
            let textField : UITextField = nameAlert.textFields![0] as UITextField
            let text : String = textField.text! as String
            var username : String
            if(text.isEmpty){
                username = "Anonymous"
            }
            else{
                username = text
            }
            
            let challengeObject = PFObject(className: "Challenge")
            challengeObject.setObject(username, forKey: "username")
            challengeObject.setObject(UIDevice.currentDevice().identifierForVendor!.UUIDString, forKey: "pushChannel")
            challengeObject.setObject(false, forKey: "jermaineCompleted")
            challengeObject.setObject(false, forKey: "userCompleted")
            challengeObject.saveInBackground()
            
            let alert = UIAlertController(title: "Challenege Sent", message: "We'll let you know when JD plays you back", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
                alert.dismissViewControllerAnimated(true, completion: nil)
                let skView = self.view as! SKView
                let gameScene : GameScene = skView.scene as! GameScene
                gameScene.setJermaineButton("WaitingJDButton")
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
        nameAlert.addAction(defaultAction)
        self.presentViewController(nameAlert, animated: true, completion: nil)
    }
    
    func applicationEnteredForeground() {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }
}
