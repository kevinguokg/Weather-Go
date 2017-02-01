//
//  Weather.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-18.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation

class Weather: NSObject, NSCoding{
    var weatherMain: String?
    var weatherDesc: String?
    var currentTemp: Double?
    var highTemp: Double?
    var lowTemp: Double?
    var humidity: Double?
    var pressure: Double?
    var windSpeed: Double?
    var windDegree: Double?
    var clouds: Double?
    var sunrize: Date?
    var sunset: Date?
    
    
    override init() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.weatherMain = aDecoder.decodeObject(forKey: "weatherMain") as? String
        self.weatherDesc = aDecoder.decodeObject(forKey: "weatherDesc") as? String
        self.currentTemp = aDecoder.decodeObject(forKey: "currentTemp") as? Double
        self.highTemp = aDecoder.decodeObject(forKey: "highTemp") as? Double
        self.lowTemp = aDecoder.decodeObject(forKey: "lowTemp") as? Double
        self.humidity = aDecoder.decodeObject(forKey: "humidity") as? Double
        self.pressure = aDecoder.decodeObject(forKey: "pressure") as? Double
        self.windSpeed = aDecoder.decodeObject(forKey: "windSpeed") as? Double
        self.windDegree = aDecoder.decodeObject(forKey: "windDegree") as? Double
        self.clouds = aDecoder.decodeObject(forKey: "clouds") as? Double
        self.sunrize = aDecoder.decodeObject(forKey: "sunrize") as? Date
        self.sunset = aDecoder.decodeObject(forKey: "sunset") as? Date
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(weatherMain, forKey: "weatherMain")
        aCoder.encode(weatherDesc, forKey: "weatherDesc")
        aCoder.encode(currentTemp, forKey: "currentTemp")
        aCoder.encode(highTemp, forKey: "highTemp")
        aCoder.encode(lowTemp, forKey: "lowTemp")
        aCoder.encode(humidity, forKey: "humidity")
        aCoder.encode(pressure, forKey: "pressure")
        aCoder.encode(windSpeed, forKey: "windSpeed")
        aCoder.encode(windDegree, forKey: "windDegree")
        aCoder.encode(clouds, forKey: "clouds")
        aCoder.encode(sunrize, forKey: "sunrize")
        aCoder.encode(sunset, forKey: "sunset")
        
    }

    
    
}
