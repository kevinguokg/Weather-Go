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
    static let weatherByCityEndPint = "api.openweathermap.org/data/2.5/weather?q="
    
    static func queryWeatherWithCityName(_ name: String, countryCode: String, completion: @escaping (Any?, Error?) -> Void) -> Void {
        let url = protocolName + weatherByCityEndPint + name + (countryCode == "" ? "" :",\(countryCode)") + "&appid=\(appKey)"
        let escapedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(escapedUrl ?? url).responseJSON { (response) in
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
