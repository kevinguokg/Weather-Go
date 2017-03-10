//
//  ShortCutManager.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-03-09.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

enum ShortCutItemType: String {
    case add = "ShortCutItemType.Add"
}

class ShortCutManager {
    static var sharedInstance: ShortCutManager = ShortCutManager()
    
    init() {
        setUp()
    }
    
    private func setUp(){
        
        let addCityItem = UIApplicationShortcutItem(type: ShortCutItemType.add.rawValue, localizedTitle: "Add City", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.add) , userInfo: nil)
        
        UIApplication.shared.shortcutItems = [addCityItem]
    }
    
    func shortCurItems() -> [UIApplicationShortcutItem]? {
        return UIApplication.shared.shortcutItems
    }
    
}
