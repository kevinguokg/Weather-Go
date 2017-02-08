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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var currTempView: UILabel!
    @IBOutlet weak var currWeatherView: UILabel!
    @IBOutlet weak var currDegreeUnitView: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    var currentCity: City!
    
    
    // need to understand how constructor works
//    convenience init(city: City) {
//        self.init()
//        self.currentCity = city
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panEdgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        panEdgeGesture.edges = .left
        self.view.addGestureRecognizer(panEdgeGesture)
        
        if let city = self.currentCity {
            self.title = city.name
            
            if let weather = city.weather {
                
                self.setBackgroundImageForCity(city: city)
                
                if #available(iOS 10.0, *) {
                    let isMetric = UserDefaults.standard.bool(forKey: "isMetric")
                    
                    var curTempUnit = Measurement(value: city.weather!.currentTemp!, unit: UnitTemperature.celsius)
                    
                    if !isMetric {
                        curTempUnit = curTempUnit.converted(to: UnitTemperature.fahrenheit)
                    }
                    self.currTempView.text = "\(Int(curTempUnit.value))"
                    self.currDegreeUnitView.text = "\(curTempUnit.unit.symbol)"
                    
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
    
    func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
             print("Screen edge swiped!")
        }
    }

    private func setBackgroundImageForCity(city: City) {
        let date = Date()
        // determine sunrise
        if let sunrise = city.weather?.sunrize, let sunset = city.weather?.sunset {
            if sunrise < date && date < sunset {
                // sunrise...
                if let weatherType = city.weather?.weatherMain {
                    switch weatherType {
                    case "Clear":
                        self.updateCellBackgoundImage(named: "sunny_day")
                        break
                        
                    case "Rain", "Drizzle":
                        self.updateCellBackgoundImage(named: "rainy_day")
                        break
                        
                    case "Snow":
                        self.updateCellBackgoundImage(named: "snowy_day")
                        break
                        
                    case "Clouds":
                        self.updateCellBackgoundImage(named: "cloudy_day")
                        break
                        
                    case "Mist", "Haze":
                        self.updateCellBackgoundImage(named: "fog_day")
                        break
                        
                    case "Extreme":
                        break
                    default:
                        break
                    }
                }
                
                
            } else {
                // sunset...
                if let weatherType = city.weather?.weatherMain {
                    switch weatherType {
                    case "Clear":
                        self.updateCellBackgoundImage(named: "sunny_night")
                        break
                        
                    case "Rain", "Drizzle":
                        self.updateCellBackgoundImage(named: "rainy_day")
                        break
                        
                    case "Snow":
                        self.updateCellBackgoundImage(named: "snowy_night")
                        break
                        
                    case "Clouds":
                        self.updateCellBackgoundImage(named: "cloudy_day")
                        break
                        
                    case "Mist", "Haze":
                        self.updateCellBackgoundImage(named: "fog_day")
                        break
                        
                    case "Extreme":
                        break
                    default:
                        break
                    }
                }
                
                
            }
            
        }
    }
    
    private func updateCellBackgoundImage(named: String) {
        self.backgroundView.image = UIImage(named: named)
    }
    
}
