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
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!
    
    @IBOutlet weak var cityLocalTimeLabel: UILabel!
    
    var city: City? = nil
    
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
            if sunrise < date && date > sunset {
                // sunrise...
                //self.backgroundColor = UIColor.blue
            } else {
                // sunset...
                //self.backgroundColor = UIColor.darkGray
            }

        }
        
    }
    
    func updateCell(){
        if let city = self.city {
            updateCell(city)
        }
    }
}
