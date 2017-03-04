//
//  City.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-18.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation

class City: NSObject, NSCoding {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var countryCode: String
    var weather: Weather?
    var timezone: TimeZone?
    var forecast: Array<ForecastWeather>?
    var needsUpdate: Bool = false
    
    init(id: String, name: String, latitude: Double, longitude: Double, countryCode: String) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.countryCode = countryCode
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObject(forKey: "id") as! String
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.latitude = aDecoder.decodeDouble(forKey: "latitude")
        self.longitude = aDecoder.decodeDouble(forKey: "longitude")
        self.countryCode = aDecoder.decodeObject(forKey: "countryCode") as! String
        self.weather = aDecoder.decodeObject(forKey: "weather") as? Weather
        self.timezone = aDecoder.decodeObject(forKey: "timezone") as? TimeZone
        self.forecast = aDecoder.decodeObject(forKey: "forecast") as? Array<ForecastWeather>
        self.needsUpdate = aDecoder.decodeBool(forKey: "needsUpdate") as! Bool
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(countryCode, forKey: "countryCode")
        aCoder.encode(weather, forKey: "weather")
        aCoder.encode(timezone, forKey: "timezone")
        aCoder.encode(forecast, forKey: "forecast")
        aCoder.encode(needsUpdate, forKey: "needsUpdate")
    }
    
    
}
