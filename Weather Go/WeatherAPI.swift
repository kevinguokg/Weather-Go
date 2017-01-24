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

protocol WeatherAPIDelegate {
    func handleJsonData(_ jsonData: Any)
}

class WeatherAPI {
    static var delegate: WeatherAPI?
    
    static let appKey = "69872ee3396e10cf77e77b72f9ba81ca"
    static let protocolName = "http://"
    static let weatherByCityEndPoint = "api.openweathermap.org/data/2.5/weather?q="
    static let weatherByCityIdEndPoint = "api.openweathermap.org/data/2.5/weather?id="
    static let forecastByCityIdEndPoint = "api.openweathermap.org/data/2.5/forecast?id="
    
    static func queryWeatherWithCityName(_ name: String, units: String = "metric", countryCode: String, completion: @escaping (Any?, Error?) -> Void) -> Void {
        let url = protocolName + weatherByCityEndPoint + name + (countryCode == "" ? "" :",\(countryCode)") + "&units=\(units)" + "&appid=\(appKey)"
        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        requestBy(escapedUrl, defaultUrl: url, completion: completion)
    }
    
    static func queryWeatherWithCityId(_ cityId: String, units: String = "metric", completion: @escaping (Any?, Error?) -> Void) -> Void{
        let url = protocolName + weatherByCityIdEndPoint + cityId + "&units=\(units)" + "&appid=\(appKey)"
        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        requestBy(escapedUrl, defaultUrl: url, completion: completion)
    }
    
    static func queryForecastWithCityId(_ cityId: String, units: String = "metric", completion: @escaping (Any?, Error?) -> Void) -> Void {
        let url = protocolName + forecastByCityIdEndPoint + cityId + "&units=\(units)" + "&appid=\(appKey)"
        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        requestBy(escapedUrl, defaultUrl: url, completion: completion)
    }
    
    private static func requestBy(_ escapedUrl: String?, defaultUrl: String, completion: @escaping (Any?, Error?) -> Void) -> Void {
        Alamofire.request(escapedUrl ?? defaultUrl).responseJSON { (response) in
            if let err = response.error {
                completion(nil, err)
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
