//
//  UserDefaultManager.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-24.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation

class UserDefaultManager {
    static func addCityToUserDefault(_ array: Array<Any>, withKey key: String){
        // add city to user defaults
        let defaults = UserDefaults.standard
        let archivedArray: NSMutableArray = NSMutableArray()
        for city in array {
            let data = NSKeyedArchiver.archivedData(withRootObject: city)
            archivedArray.add(data)
        }
        defaults.set(archivedArray, forKey: key)
    }
    //cityList
}
