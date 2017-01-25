//
//  CityWeatherDetailViewController.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-23.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class CityWeatherDetailViewController: UIViewController {
    @IBOutlet weak var currTempView: UILabel!
    @IBOutlet weak var currWeatherView: UILabel!
    @IBOutlet weak var currDegreeUnitView: UILabel!
    
    var currentCity: City!
    
    
    // need to understand how constructor works
//    convenience init(city: City) {
//        self.init()
//        self.currentCity = city
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let city = self.currentCity {
            self.title = city.name
            
            if let weather = city.weather {
                
                if #available(iOS 10.0, *) {
                    let curTempCel = Measurement(value: city.weather!.currentTemp!, unit: UnitTemperature.celsius)
                    self.currTempView.text = "\(Int(curTempCel.value))"
                    self.currDegreeUnitView.text = "\(curTempCel.unit.symbol)"
                    
                } else {
                    // Fallback on earlier versions
                    self.currTempView.text = "\(Int(round(weather.currentTemp!)))"
                }
                
                self.currWeatherView.text = city.weather?.weatherDesc
                
            }
            
            
            WeatherAPI.queryForecastWithCityId(city.id, units: "metric", completion: { (jsonData, error) in
                if let err = error {
                    print("ERR: \(err)")
                } else {
                    if let json = jsonData {
                        let forecastJson = JSON(json)
                        let countryCode = forecastJson["city"]["country"]
                        print(countryCode)
                        
                    }
                }
            })
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
