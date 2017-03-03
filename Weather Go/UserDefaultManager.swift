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
//        let archivedArray: NSMutableArray = NSMutableArray()
        var archivedArray = Array<Any>()
        for city in array {
            let data = NSKeyedArchiver.archivedData(withRootObject: city)
            archivedArray.append(data)
        }
        defaults.set(archivedArray, forKey: key)
        defaults.synchronize()
    }
    
    static func addTheCityToUserDefault(city: City) {
        var cityUpdated = false
        let defaults = UserDefaults.standard
        if let cityList = defaults.object(forKey: "cityList") as? Array<Any> {
            for data in cityList{
                if var theCity = NSKeyedUnarchiver.unarchiveObject(with:data as! Data) as? City {
                    if theCity.id == city.id {
                        theCity = city
                        cityUpdated = true
                    }
                }
            }
            
            if cityUpdated {
                addCityToUserDefault(cityList, withKey: "cityList")
            }
        }
    }
}
