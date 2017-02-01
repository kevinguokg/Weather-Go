//
//  CityWeatherCell.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-24.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import TimeZoneLocate

class CityWeatherCell: UITableViewCell {
    
    @IBOutlet weak var backgroundWeatherView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!
    
    @IBOutlet weak var cityLocalTimeLabel: UILabel!
    
    var city: City? = nil
    var imageHeight: CGFloat {
        get {
            return self.backgroundWeatherView!.bounds.height
        }
    }
    
    var currentOffset: CGPoint? = nil
    let offsetSpeed: CGFloat = 10.0
    
    func offset(offset: CGPoint) {
//        self.backgroundView?.frame = (self.backgroundView?.bounds)!.offsetBy(dx: offset.x, dy: offset.y)
        
        if self.currentOffset == nil {
            UIView.animate(withDuration: 0.1) {
                self.backgroundWeatherView?.frame = (self.backgroundWeatherView?.bounds)!.offsetBy(dx: offset.x, dy: offset.y)
            }
            
        } else {
            self.backgroundWeatherView?.frame = (self.backgroundWeatherView?.bounds)!.offsetBy(dx: offset.x, dy: offset.y)
        }
        
        
        currentOffset = offset
    }
    
    
    func updateCell(_ city: City) {
        self.city = city
        cityNameLabel.text = city.name
        
        let date = Date()
        
        if let timezone = TimeZoneLocate.timeZoneWithLocation(CLLocation(latitude: city.latitude, longitude: city.longitude), countryCode: city.countryCode) {
//            print(timezone)
            let formatter = DateFormatter()
            formatter.timeZone = timezone
            formatter.dateFormat = "hh:mm a"
            cityLocalTimeLabel.text = formatter.string(from: date)
        } else {
            cityLocalTimeLabel.text = ""
        }
        
        if #available(iOS 10.0, *) {
            let curTempCel = Measurement(value: city.weather!.currentTemp!, unit: UnitTemperature.celsius)

            cityTempLabel.text = "\(Int(curTempCel.value))\(curTempCel.unit.symbol)"
        } else {
            // Fallback on earlier versions
            cityTempLabel.text = "\(Int((city.weather?.currentTemp!)!))"
        }
        
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
//        let imageView = UIImageView(image: UIImage(named: named))
//        imageView.contentMode = .scaleAspectFill
//        self.backgroundView = imageView
        
        self.backgroundWeatherView.image = UIImage(named: named)
        //self.offset(offset: self.currentOffset)
        
    }
    
    func updateCell(){
        if let city = self.city {
            updateCell(city)
        }
    }
}
