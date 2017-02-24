//
//  ForecastWeatherCell.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-07.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class ForecastWeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var precipImageView: UIImageView!
    @IBOutlet weak var precipLabel: UILabel!
    
    var city: City? = nil
    var forecastWeather: ForecastWeather? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateCell() {
        updateCellBackgroundImage()
    }
    
    private func updateCellBackgroundImage() {
        
        guard let city = self.city, let forecastWeather = forecastWeather, let currForecastDate = forecastWeather.time else {
            return
        }
        
        let isDayTime: Bool = self.isDayTime(date: currForecastDate)
        
        if let weatherType = forecastWeather.weatherMain {
            switch weatherType {
            case "Clear":
                isDayTime ? self.updateWeatherIcon(named: "icon_sunny_day") : self.updateWeatherIcon(named: "icon_sunny_night")
                break
                
            case "Rain", "Drizzle":
                isDayTime ? self.updateWeatherIcon(named: "icon_precip_rainy") : self.updateWeatherIcon(named: "icon_precip_rainy")
                break
                
            case "Snow":
                isDayTime ? self.updateWeatherIcon(named: "icon_snow") : self.updateWeatherIcon(named: "icon_snow")
                break
                
            case "Clouds":
                isDayTime ? self.updateWeatherIcon(named: "icon_cloudy_day") : self.updateWeatherIcon(named: "icon_cloudy_day")
                break
                
            case "Mist", "Haze":
                isDayTime ? self.updateWeatherIcon(named: "icon_fog") : self.updateWeatherIcon(named: "icon_fog")
                break
                
            case "Extreme":
                isDayTime ? self.updateWeatherIcon(named: "icon_storm") : self.updateWeatherIcon(named: "icon_storm")
                break
            default:
                break
            }
        }

       
    }
    
    private func updateWeatherIcon(named: String) {
        self.weatherImageView.image = UIImage(named: named)
    }
    
    
    private func isDayTime(date: Date) -> Bool {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H"
        if let timezone = self.city!.timezone {
            timeFormatter.timeZone = timezone
        }
        let hourString = timeFormatter.string(from: date)
        
        return Int(hourString)! >= 6 && Int(hourString)! < 18
    }
}
