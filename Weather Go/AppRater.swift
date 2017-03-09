//
//  AppRater.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-03-09.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class AppRater: NSObject {
    
    let iTunesStoreRatingUrl: String = "itms-apps://itunes.apple.com/app/id"
    
    static var sharedInstance = AppRater()
    
    var appId: String!
    
    var application = UIApplication.shared
    var userDefaults = UserDefaults.standard
    let requiredLaunchBeforeRating = 10
    
    override init() {
        super.init()
        setUp()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
    }
    
    func setUp() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidFinishedLaunching), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
    }
    
    // MARK: Notification observers
    func appDidFinishedLaunching(notif: Notification) {
        if let application = notif.object as? UIApplication {
            self.application = application
            displayRatingsPromptIfRequired()
        }
    }
    
    // MARK: Launch count
    func getAppLaunchCount() -> Int {
        return userDefaults.integer(forKey: kAppLaunchCount)
    }
    
    func incrementAppLaunches() {
        userDefaults.set( (getAppLaunchCount() + 1), forKey: kAppLaunchCount)
        userDefaults.synchronize()
    }
    
    func resetAppLaunches() {
        userDefaults.set(0, forKey: kAppLaunchCount)
        userDefaults.synchronize()
    }
    
    // MARK: Launch Date
    func getAppFirstLaunchDate() -> Date {
        if let date = userDefaults.value(forKey: kAppInstallDate) as? Date {
            return date
        } else {
            return Date()
        }
    }
    
    func setAppFirstLaunchDate() {
        userDefaults.set(Date(), forKey: kAppInstallDate)
        userDefaults.synchronize()
    }
    
    
    // MARK: App rating
    func hasShownAppRating() -> Bool {
        return userDefaults.bool(forKey: "kAppRatingHasShwon")
    }
    
    func setAppShownRating() {
        userDefaults.set(true, forKey: "kAppRatingHasShwon")
        userDefaults.synchronize()
    }
    
    private func displayRatingsPromptIfRequired() {
        if hasShownAppRating() {
            return
        }
        
        let appCount = getAppLaunchCount()
        if appCount >= requiredLaunchBeforeRating {
            rateApp()
        }
        
        incrementAppLaunches()
    }
    
    private func rateApp(){
        let rateAlert = UIAlertController(title: "Rate Us", message: "Enjoy using this app? Please rate us if you have 30 seconds!", preferredStyle: UIAlertControllerStyle.alert)
        rateAlert.addAction(UIAlertAction(title: "Not Now", style: UIAlertActionStyle.cancel, handler: { (action) in
            self.resetAppLaunches()
        }))
        
        rateAlert.addAction(UIAlertAction(title: "Never", style: UIAlertActionStyle.destructive, handler: { (action) in
            self.setAppShownRating()
        }))
        
        rateAlert.addAction(UIAlertAction(title: "Rate Us!", style: UIAlertActionStyle.default, handler: { (action) in
            if let url = (URL(string: "\(self.iTunesStoreRatingUrl)/\(self.appId!)")) {
                self.application.openURL(url)
                self.setAppShownRating()
            }
        }))
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.application.windows[0].rootViewController?.present(rateAlert, animated: true, completion: nil)
        }
    }
}
