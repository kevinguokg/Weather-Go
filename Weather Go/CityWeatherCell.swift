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
                
                //(self.backgroundWeatherView?.bounds)!.
                
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
    
    
    func updateCell(_ city: City) {
        self.city = city
        cityNameLabel.text = city.name
        
        let date = Date()
        
        if let timezone = self.city?.timezone {
            let formatter = DateFormatter()
            formatter.timeZone = timezone
            formatter.dateFormat = "hh:mm a"
            cityLocalTimeLabel.text = formatter.string(from: date)
        } else {
            cityLocalTimeLabel.text = ""
        }
        
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
                        self.updateCellBackgoundImage(named: "sunny_day")
                        break
                      
                    case "Rain", "Drizzle":
                        self.updateCellBackgoundImage(named: "rainy_day")
                        
                        setUpEmitterLayer()
                        setUpEmitterCell()
                        emitterLayer.emitterCells = [emitterCell]
                        self.backgroundWeatherView?.layer.addSublayer(emitterLayer)
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
                        
                        setUpEmitterLayer()
                        setUpEmitterCell()
                        emitterLayer.emitterCells = [emitterCell]
                        self.backgroundWeatherView?.layer.addSublayer(emitterLayer)
                        
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
        
        
        //if let offset = self.currentOffset {
        //    self.offset(offset: offset)
        //}
        
        
    }
    
    func updateCell(){
        if let city = self.city {
            updateCell(city)
        }
    }
    
    func setUpEmitterLayer() {
        emitterLayer.frame = self.backgroundWeatherView.bounds
        emitterLayer.seed = UInt32(NSDate().timeIntervalSince1970)
        emitterLayer.renderMode = kCAEmitterLayerAdditive
        emitterLayer.drawsAsynchronously = true
        //emitterLayer.backgroundColor = UIColor.gray.cgColor
        setEmitterPosition()
    }
    
    // 3
    func setUpEmitterCell() {
        emitterCell.contents = UIImage(named: "particle_rain")?.cgImage
        
        emitterCell.lifetime = 3.0
        emitterCell.birthRate = 150.0
        
        emitterCell.velocity = 1600.0
        emitterCell.velocityRange = 100.0
        
        emitterCell.emissionLatitude = degreesToRadians(271)
        emitterCell.emissionLongitude = degreesToRadians(300)
        emitterCell.emissionRange = degreesToRadians(0)
        
        emitterCell.xAcceleration = -50
        emitterCell.yAcceleration = 1000
        emitterCell.zAcceleration = 0
        
        emitterCell.alphaRange = 0.2
        emitterCell.scale = 0.18
        
        emitterCell.color = UIColor.gray.cgColor
        emitterCell.redRange = 0.0
        emitterCell.greenRange = 0.0
        emitterCell.blueRange = 0.0
        emitterCell.alphaRange = 0.0
        emitterCell.redSpeed = 0.0
        emitterCell.greenSpeed = 0.0
        emitterCell.blueSpeed = 0.0
        emitterCell.alphaSpeed = 0
        
        //        let zeroDegreesInRadians = degreesToRadians(0.0)
        //        emitterCell.spin = degreesToRadians(130.0)
        //        emitterCell.spinRange = zeroDegreesInRadians
        //        emitterCell.emissionRange = degreesToRadians(360.0)
        
    }
    
    func degreesToRadians(_ degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
    
    func setEmitterPosition() {
        emitterLayer.emitterPosition = CGPoint(x: self.backgroundWeatherView.bounds.midX, y: self.backgroundWeatherView.bounds.minY - 50)
        emitterLayer.emitterSize = CGSize(width: self.backgroundWeatherView.bounds.width * 1.2, height: 5)
        emitterLayer.emitterShape = kCAEmitterLayerLine;
    }
}
