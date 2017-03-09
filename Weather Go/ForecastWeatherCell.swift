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
    
    var precipLayer = CAShapeLayer()
    
    let minPrecipHeight: CGFloat = 3.0
    let singleMMPrecipHeight: CGFloat = 1.5
    var maxPrecipHeight: CGFloat {
        return self.bounds.height / 3.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
    
    }
    
    func updateCell() {
        updateCellBackgroundImage()
        updateWeatherLayer()
    }
    
    private func updateWeatherLayer() {
        guard let city = self.city, let forecastWeather = forecastWeather, let currForecastDate = forecastWeather.time else {
            return
        }
        
        
        
        if let weatherType = forecastWeather.weatherMain {
            switch weatherType {
            case "Rain", "Drizzle":
                let precipRain = Int(round(forecastWeather.precipRain!))
                let layerHeight = max(singleMMPrecipHeight * CGFloat(precipRain), minPrecipHeight)
                precipLayer.path = UIBezierPath(rect: CGRect(x: 0, y: self.bounds.height - min(layerHeight, maxPrecipHeight), width: self.bounds.width, height: min(layerHeight, maxPrecipHeight))).cgPath
                    
                precipLayer.fillColor = kColorForecastPrecipRainy.cgColor
                break
                
            case "Snow":
                let precipSnow = Int(round(forecastWeather.precipSnow!))
                let layerHeight = max(singleMMPrecipHeight * CGFloat(precipSnow), minPrecipHeight)
                precipLayer.path = UIBezierPath(rect: CGRect(x: 0, y: self.bounds.height - min(layerHeight, maxPrecipHeight), width: self.bounds.width, height: min(layerHeight, maxPrecipHeight))).cgPath
                
                precipLayer.fillColor = kColorForecastPrecipSnowy.cgColor
                break

            default:
                precipLayer.fillColor = UIColor.clear.cgColor
                break
            }
         
            precipLayer.shouldRasterize = true
            
            let opacityAnim = CABasicAnimation(keyPath: "opacity")
            opacityAnim.fromValue = 0
            opacityAnim.toValue = 1
            opacityAnim.repeatCount = 0
            opacityAnim.duration = 0.8
            opacityAnim.fillMode = kCAFillModeForwards
            opacityAnim.isRemovedOnCompletion = false
            precipLayer.add(opacityAnim, forKey: "opacityAnim")
            
//            let raisingAnim = CABasicAnimation(keyPath: "bounds")
//            raisingAnim.fromValue = NSValue(cgRect: CGRect(origin: CGPoint(x:0, y: 0), size: CGSize(width: precipLayer.bounds.width, height: precipLayer.bounds.height)))
//            raisingAnim.toValue = NSValue(cgRect: precipLayer.bounds)
//            raisingAnim.repeatCount = 0
//            raisingAnim.duration = 0.8
//            raisingAnim.fillMode = kCAFillModeForwards
//            raisingAnim.isRemovedOnCompletion = false
//            precipLayer.add(raisingAnim, forKey: "raisingAnim")
            
            
            self.layer.addSublayer(precipLayer)
            
        }
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
