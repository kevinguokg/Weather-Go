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
    
    var animationLayer: [CALayer]? = nil
    var animatinTimer: Timer? = nil
    
    var currentOffset: CGPoint? = nil
    let offsetSpeed: CGFloat = 10.0
    
    func offset(offset: CGPoint) {
        if self.currentOffset == nil {
            UIView.animate(withDuration: 0.1) {
                self.backgroundWeatherView?.frame = (self.backgroundWeatherView?.bounds)!.offsetBy(dx: offset.x, dy: offset.y)
            }
            
        } else {
            self.backgroundWeatherView?.frame = (self.backgroundWeatherView?.bounds)!.offsetBy(dx: offset.x, dy: offset.y)
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
                        let weatherLayer = ClearSkyEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer, weatherLayer.createSunLightLayer()]
                        break
                      
                    case "Rain", "Drizzle":
                        //self.updateCellBackgoundImage(named: "rainy_day")
                        let weatherLayer = RainEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Thunderstorm":
                        let weatherLayer = ThunderEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        
                        // TODO animations thunder day
                        addLightning()
                        break
                    
                    case "Snow":
                        //self.updateCellBackgoundImage(named: "snowy_day")
                        let weatherLayer = SnowEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Clouds":
                        //self.updateCellBackgoundImage(named: "cloudy_day")
                        
                        let weatherLayer = CloudEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Fog", "Mist", "Haze":
                        //self.updateCellBackgoundImage(named: "fog_day")
                        let weatherLayer = FogEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day, displayType: .cell)
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
                        let weatherLayer = ClearSkyEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Rain", "Drizzle":
                        let weatherLayer = RainEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        
                        break
                        
                    case "Thunderstorm":
                        let weatherLayer = ThunderEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        addLightning()
                        break
                        
                    case "Snow":
                        let weatherLayer = SnowEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Clouds":
                        let weatherLayer = CloudEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night, displayType: .cell)
                        self.backgroundWeatherView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Fog", "Mist", "Haze":
                        let weatherLayer = FogEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .night, displayType: .cell)
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
    
    private func addLightning() {
        if animatinTimer != nil {
            animatinTimer?.invalidate()
            animatinTimer = nil
        }
        
        if #available(iOS 10.0, *) {
            animatinTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (timer) in
                self.lightningAnimation()
            }
        } else {
            // Fallback on earlier versions
            animatinTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(lightningAnimation), userInfo: nil, repeats: true)
        }
        
    }
    
    //function for managing all lightning animations
    func lightningAnimation() {
        if self.animationLayer != nil, (self.animationLayer?.count)! > 0 {
            for layer in self.animationLayer! {
                if layer is CAShapeLayer {
                    let theLayer = layer as! CAShapeLayer
                    theLayer.removeFromSuperlayer()
                }
            }
        }
        
        let weatherLayer = ThunderEffectLayer(frame: self.backgroundWeatherView.frame, dayNight: .day, displayType: .cell)
        
        // bolt layer
        let boltLayer = weatherLayer.addBoltWith(startPoint: CGPoint(x: self.backgroundWeatherView.frame.width / 2, y: 0.0), endPoint: CGPoint(x: self.backgroundWeatherView.frame.width / 3.0, y: self.backgroundWeatherView.frame.height))
        self.animationLayer = Array()
        
        self.animationLayer?.append(boltLayer)
        self.backgroundWeatherView?.layer.addSublayer(boltLayer)
        
        // flashing light layer
        let lightLayer = weatherLayer.addLightning()
        self.animationLayer?.append(lightLayer)
        self.backgroundWeatherView?.layer.addSublayer(lightLayer)
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
                        //addSumBeam()
                        break
                        
                    case "Rain", "Drizzle":
                        break
                        
                    case "Thunderstorm":
                        break
                        
                    case "Snow":
                        break
                        
                    case "Clouds":
                        addOvercastClouds()
                        break
                        
                    case "Fog", "Mist", "Haze":
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
                    
                    case "Thunderstorm":
                        break
                        
                    case "Snow":
                        break
                        
                    case "Clouds":
                        addOvercastClouds()
                        break
                        
                    case "Fog", "Mist", "Haze":
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
        cloudImage1.contentMode = .scaleAspectFill
        
        cloudImage1.alpha = 0
        cloudImage1.image = UIImage(named: "sun_beam")
        self.addSubview(cloudImage1)
        
        UIView.animate(withDuration: 20, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveEaseInOut], animations: {
            self.cloudImage1.alpha = 0.5
            self.cloudImage1.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
        }, completion: nil)
        
    }
}
