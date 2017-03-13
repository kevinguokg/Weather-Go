//
//  AppDelegate.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-17.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import UIKit
import GoogleMobileAds
import ReachabilitySwift
import JDropDownAlert

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var shortcutItem: UIApplicationShortcutItem?
    
    //declare this property where it won't go out of scope relative to your listener
    let reachability = Reachability()!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let appRater = AppRater.sharedInstance
        appRater.appId = Bundle.main.bundleIdentifier!
        
        GADMobileAds.configure(withApplicationID: kAdMobId)
        
        _ = ShortCutManager.sharedInstance
        
        setUpReachability()
        
        var launchedFromShortCut = false
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            launchedFromShortCut = true
            self.shortcutItem = shortcutItem
        }
        
        return !launchedFromShortCut
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Called when app responds to quick actions
        completionHandler(handleShortcut(shortcutItem: shortcutItem))
    }
    
    private func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool{
        guard let shortcutItemType = ShortCutItemType(rawValue: shortcutItem.type) else {
            return false
        }
        
        switch shortcutItemType {
            case ShortCutItemType.add:
                print("Going to add a city")
                NotificationCenter.default.post(name: Notification.Name.quickActionOpenAddCityVc , object: nil, userInfo: nil)
                break
            }
        
        return true
    }
    
    func triggerShortcutItem() {
        if let shortcut = self.shortcutItem {
            _ = handleShortcut(shortcutItem: shortcut)
        }
        
        // reset
        self.shortcutItem = nil
    }
    
    private func setUpReachability() {
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async(execute: {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
                
//                let alert = JDropDownAlert(position: AlertPosition.top, direction: AnimationDirection.normal)
//                alert.alertWith("Awesome!", message: "You are connected to the Internet.", topLabelColor: UIColor.white, messageLabelColor: UIColor.white, backgroundColor: kColorAlertGood, delay: 3)
            })
        }
        
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            DispatchQueue.main.async(execute: {
                print("Not reachable")
                let alert = JDropDownAlert(position: AlertPosition.top, direction: AnimationDirection.normal)
                alert.alertWith("Oops..", message: "Your lost your Internet connectivity.", topLabelColor: UIColor.white, messageLabelColor: UIColor.white, backgroundColor: kColorAlertBad, delay: 3)
            })
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

