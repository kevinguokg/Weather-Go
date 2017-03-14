//
//  WeatherAPI.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-17.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

protocol WeatherAPIDelegate {
    func handleJsonData(_ jsonData: Any)
}

class WeatherAPI {
    static var delegate: WeatherAPI?
    
    static let appKey = "69872ee3396e10cf77e77b72f9ba81ca"
    static let protocolName = "http://"
    static let weatherByCityEndPoint = "api.openweathermap.org/data/2.5/weather?q="
    static let weatherByCityIdEndPoint = "api.openweathermap.org/data/2.5/weather?id="
    static let weatherByCoordEndPoint = "api.openweathermap.org/data/2.5/weather?lat="
    static let forecastByCityIdEndPoint = "api.openweathermap.org/data/2.5/forecast?id="
    
    static let retryCount = 10
    
    static func queryWeatherWithCityName(_ name: String, units: String = "metric", countryCode: String, completion: @escaping (Any?, Error?) -> Void) {
        let url = protocolName + weatherByCityEndPoint + name + (countryCode == "" ? "" :",\(countryCode)") + "&units=\(units)" + "&appid=\(appKey)"
        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        requestBy(escapedUrl, defaultUrl: url, retry: retryCount, completion: completion)
    }
    
    static func queryWeatherWithCityId(_ cityId: String, units: String = "metric", completion: @escaping (Any?, Error?) -> Void) {
        let url = protocolName + weatherByCityIdEndPoint + cityId + "&units=\(units)" + "&appid=\(appKey)"
        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        requestBy(escapedUrl, defaultUrl: url, retry: retryCount, completion: completion)
    }
    
    
    static func queryWeatherWithLocation(_ location: CLLocation, units: String = "metric", completion: @escaping (Any?, Error?) -> Void ) {
        let url = protocolName + weatherByCoordEndPoint + "\(location.coordinate.latitude)" + "&lon=\(location.coordinate.longitude)" + "&units=\(units)" + "&appid=\(appKey)"
        requestBy(url, defaultUrl: url, retry: retryCount, completion: completion)
    }
    
    static func queryForecastWithCityId(_ cityId: String, units: String = "metric", completion: @escaping (Any?, Error?) -> Void){
        let url = protocolName + forecastByCityIdEndPoint + cityId + "&units=\(units)" + "&appid=\(appKey)"
        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        requestBy(escapedUrl, defaultUrl: url, retry: retryCount, completion: completion)
    }
    
    private static func requestBy(_ escapedUrl: String?, defaultUrl: String, retry: Int, completion: @escaping (Any?, Error?) -> Void) {
        var retryNum = retry
        Alamofire.request(escapedUrl ?? defaultUrl)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
            if let err = response.error {
                completion(nil, err)
                if retryNum > 0 {
                    retryNum -= 1
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: { 
                        requestBy(escapedUrl, defaultUrl: defaultUrl, retry: retryNum, completion: completion)
                    })
                    
                } else {
                    // retry too many times
                }
            } else {
                print(response.request!)  // original URL request
                print(response.response!) // HTTP URL response
                print(response.data! as Any)     // server data
                print(response.result)   // result of response serialization
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    completion(json, response.error)
                }
            }
            
        }
    }
}
