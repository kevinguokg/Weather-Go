//
//  Weather.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-18.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation

class Weather: NSObject, NSCoding {
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
    var precipRain: Double?
    var precipSnow: Double?
    
    
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
        self.precipRain = aDecoder.decodeObject(forKey: "precipRain") as? Double
        self.precipSnow = aDecoder.decodeObject(forKey: "precipSnow") as? Double
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
        aCoder.encode(precipRain, forKey: "precipRain")
        aCoder.encode(precipRain, forKey: "precipSnow")
        
    }

    func degreeToString(degree: Double?) -> String? {
        var degreeStr: String? = nil
        guard let degree = degree, degree >= 0 else {
            return degreeStr
        }
        
        if degree >= 350 && degree <= 10 {
            degreeStr = "N"
        } else if degree > 10 && degree < 80 {
            degreeStr = "NE"
        } else if degree >= 80 && degree <= 100 {
            degreeStr = "E"
        } else if degree > 100 && degree < 170 {
            degreeStr = "SE"
        } else if degree >= 170 && degree <= 190 {
            degreeStr = "S"
        } else if degree > 190 && degree < 260 {
            degreeStr = "SW"
        } else if degree >= 260 && degree <= 280 {
            degreeStr = "W"
        } else if degree > 280 && degree < 350 {
            degreeStr = "NW"
        } else {
            degreeStr = "N"
        }
        
        return degreeStr
    }
    
}
