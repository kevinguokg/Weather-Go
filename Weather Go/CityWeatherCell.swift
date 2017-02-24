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

class CityWeatherCell: UITableViewCell {
    
    @IBOutlet weak var backgroundWeatherView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityTempLabel: UILabel!
    
    @IBOutlet weak var cityLocalTimeLabel: UILabel!
    @IBOutlet weak var imgBackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgBackBottomConstraint: NSLayoutConstraint!
    
    let emitterLayer = CAEmitterLayer()
    let emitterCell = CAEmitterCell()
    
    var cloudImage1: UIImageView!
    var cloudImage2: UIImageView!
    
    var imgPos1: CGFloat?
    var imgPos2: CGFloat?
    
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

                //self.imgBackTopConstraint.constant -= offset.y
                //self.imgBackBottomConstraint.constant += offset.y
                
            }
            
        } else {
            self.backgroundWeatherView?.frame = (self.backgroundWeatherView?.bounds)!.offsetBy(dx: offset.x, dy: offset.y)
            
            //self.imgBackTopConstraint.constant -= offset.y
            //self.imgBackBottomConstraint.constant += offset.y
        }
        
        
        currentOffset = offset
    }
    
    func updateCellTime() {
        if let city = self.city {
            let date = Date()
            
            if let timezone = self.city?.timezone {
                let formatter = DateFormatter()
                formatter.timeZone = timezone
                formatter.dateFormat = "h:mm a"
                cityLocalTimeLabel.text = formatter.string(from: date)
            } else {
                cityLocalTimeLabel.text = ""
            }
        }
    }
    
    func updateCell(_ city: City) {
        self.city = city
        cityNameLabel.text = city.name
        
        updateCellTime()
        
        let date = Date()
        
        if #available(iOS 10.0, *) {
            let isMetric = UserDefaults.standard.bool(forKey: "isMetric")
            var curTempUnit = Measurement(value: city.weather!.currentTemp!, unit: UnitTemperature.celsius)

            if !isMetric {
                curTempUnit = curTempUnit.converted(to: UnitTemperature.fahrenheit)
            }
            
            cityTempLabel.text = "\(Int(curTempUnit.value))\(curTempUnit.unit.symbol)"
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
                        //self.updateCellBackgoundImage(named: "sunny_day")
                        let weatherLayer = ClearSkyEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                      
                    case "Rain", "Drizzle":
                        //self.updateCellBackgoundImage(named: "rainy_day")
                        let weatherLayer = RainEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                    
                    case "Snow":
                        //self.updateCellBackgoundImage(named: "snowy_day")
                        let weatherLayer = SnowEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Clouds":
                        //self.updateCellBackgoundImage(named: "cloudy_day")
                        
                        let weatherLayer = CloudEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Mist", "Haze":
                        //self.updateCellBackgoundImage(named: "fog_day")
                        let weatherLayer = FogEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
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
                        //self.updateCellBackgoundImage(named: "sunny_night")
                        let weatherLayer = ClearSkyEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Rain", "Drizzle":
                        //self.updateCellBackgoundImage(named: "rainy_day")
                        
                        let weatherLayer = RainEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        
                        break
                        
                    case "Snow":
                        //self.updateCellBackgoundImage(named: "snowy_night")
                        let weatherLayer = SnowEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Clouds":
                        //self.updateCellBackgoundImage(named: "cloudy_day")
                        
                        let weatherLayer = CloudEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Mist", "Haze":
                        //self.updateCellBackgoundImage(named: "fog_day")
                        let weatherLayer = FogEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
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
        //self.backgroundWeatherView.image = UIImage(named: named)
    }
    
    func stopAnimatingEffects() {
        if cloudImage1 != nil {
            cloudImage1.removeFromSuperview()
            cloudImage1 = nil
        }
        
        if cloudImage2 != nil {
            cloudImage2.removeFromSuperview()
            cloudImage2 = nil
        }
    }
    
    func animateEffects() {
        guard let city = self.city else {
            return
        }
        
        let date = Date()
        // determine sunrise
        if let sunrise = city.weather?.sunrize, let sunset = city.weather?.sunset {
            if sunrise < date && date < sunset {
                // sunrise...
                if let weatherType = city.weather?.weatherMain {
                    switch weatherType {
                    case "Clear":
                        addSumBeam()
                        break
                        
                    case "Rain", "Drizzle":

                        break
                        
                    case "Snow":
                        break
                        
                    case "Clouds":
                        addOvercastClouds()
                        break
                        
                    case "Mist", "Haze":
                        addFogClouds()
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
                        break
                        
                    case "Rain", "Drizzle":
                        break
                        
                    case "Snow":
                        break
                        
                    case "Clouds":
                        addOvercastClouds()
                        break
                        
                    case "Mist", "Haze":
                        addFogClouds()
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
    
    private func addOvercastClouds() {
        if self.cloudImage1 != nil && self.cloudImage2 != nil {
            return
        }
        
        let xCoord = self.imgPos1 ?? CGFloat(arc4random_uniform(UInt32(self.frame.width / 2))) // generate a random number
        cloudImage1 = UIImageView(frame: CGRect(x: xCoord, y: 0, width: self.frame.width, height: self.frame.height))
        cloudImage1.clipsToBounds = true
        cloudImage1.contentMode = .scaleAspectFill
        
        cloudImage1.alpha = 0.3
        cloudImage1.image = UIImage(named: "cloud_clear_1")
        self.addSubview(cloudImage1)
        
        UIView.animate(withDuration: 45, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveEaseInOut], animations: {
            self.cloudImage1.center.x += 200
        }, completion: nil)
        
        let xCoord2 = self.imgPos2 ?? CGFloat(arc4random_uniform(UInt32(self.frame.width / 2))) * 2 // generate a random number
        cloudImage2 = UIImageView(frame: CGRect(x: xCoord2, y: 0, width: self.frame.width * 0.8, height: self.frame.height))
        cloudImage2.clipsToBounds = true
        cloudImage2.alpha = 0.2
        cloudImage2.image = UIImage(named: "cloud_clear_1")
        cloudImage2.contentMode = .scaleAspectFill
        self.addSubview(cloudImage2)
        
        UIView.animate(withDuration: 50, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveLinear], animations: {
            self.cloudImage2.center.x -= 200
        }, completion: nil)
    }
    
    private func addFogClouds() {
        if self.cloudImage1 != nil && self.cloudImage2 != nil {
            return
        }
        
        let xCoord = self.imgPos1 ?? CGFloat(arc4random_uniform(UInt32(self.frame.width / 2))) // generate a random number
        cloudImage1 = UIImageView(frame: CGRect(x: xCoord, y: 0, width: self.frame.width * 1.5, height: self.frame.height))
        cloudImage1.clipsToBounds = true
        cloudImage1.contentMode = .scaleAspectFill
        
        cloudImage1.alpha = 1
        cloudImage1.image = UIImage(named: "cloud_fog")
        self.addSubview(cloudImage1)
        
        UIView.animate(withDuration: 45, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveEaseInOut], animations: {
            self.cloudImage1.center.x += 200
        }, completion: nil)
        
        let xCoord2 = self.imgPos2 ?? CGFloat(arc4random_uniform(UInt32(self.frame.width / 2))) * 2 // generate a random number
        cloudImage2 = UIImageView(frame: CGRect(x: xCoord2, y: 0, width: self.frame.width, height: self.frame.height))
        cloudImage2.clipsToBounds = true
        cloudImage2.alpha = 0.8
        cloudImage2.image = UIImage(named: "cloud_fog")
        cloudImage2.contentMode = .scaleAspectFill
        self.addSubview(cloudImage2)
        
        UIView.animate(withDuration: 50, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveLinear], animations: {
            self.cloudImage2.center.x -= 200
        }, completion: nil)
    }
    
    private func addSumBeam() {
        if self.cloudImage1 != nil {
            return
        }
        
        cloudImage1 = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        cloudImage1.clipsToBounds = true
        cloudImage1.contentMode = .scaleAspectFit
        
        cloudImage1.alpha = 0
        cloudImage1.image = UIImage(named: "sun_beam")
        self.addSubview(cloudImage1)
        
        UIView.animate(withDuration: 20, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveEaseInOut], animations: {
            self.cloudImage1.alpha = 0.9
            self.cloudImage1.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        }, completion: nil)
        
    }
    
}
