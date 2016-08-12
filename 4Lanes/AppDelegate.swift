
//
//  AppDelegate.swift
//  4Lanes
//
//  Created by Sean Hubbard on 1/2/15.
//  Copyright (c) 2015 That Level LLC. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ChartboostDelegate {
    
    var window: UIWindow?
    var backgroundMusicPlayer: BackgroundMusicPlayer?
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //initialize Parse
        Parse.setApplicationId(kParseApplicationId, clientKey: kParseClientKey)
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
        else {
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        backgroundMusicPlayer = BackgroundMusicPlayer()
        var muted = defaults.boolForKey("muted")
        if muted == false {
            backgroundMusicPlayer?.play()
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        backgroundMusicPlayer?.stop()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        backgroundMusicPlayer?.stop()
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        var muted = defaults.boolForKey("muted")
        if muted == false {
            backgroundMusicPlayer?.play()
        }
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        var muted = defaults.boolForKey("muted")
        if muted == false {
            backgroundMusicPlayer?.play()
        }
        
        // Chartboost
        if kUseChartboost == 1 {
            Chartboost.startWithAppId(kChartboostAppID, appSignature: kChartboostAppSignature, delegate: self);
            Chartboost.cacheMoreApps(CBLocationHomeScreen)
        }
        
        // Revmob
        if kUseRevmob == 1 {
            RevMobAds.startSessionWithAppID(kRevmobAppID,
                withSuccessHandler: nil, andFailHandler: nil);
        }
        
        // Vungle
        if kUseVungle == 1 {
            VungleSDK.sharedSDK().startWithAppId(kVungleAppID)
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        backgroundMusicPlayer?.stop()
    }
    
    
    
    
    
    
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("did register for notifications")
        var installation = PFInstallation.currentInstallation()
        installation.setObject(UIDevice.currentDevice().identifierForVendor!.UUIDString, forKey: "pushChannel")
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
//    func shouldDisplayInterstitial(location: String!) -> Bool {
//        backgroundMusicPlayer?.pause()
//        return true
//    }
//    
//    func didDismissInterstitial(location: String!) {
//        backgroundMusicPlayer?.play()
//    }
}

