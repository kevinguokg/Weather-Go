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

class CityWeatherDetailViewController: UIViewController, UIScrollViewDelegate {
    // General UIs
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    // Basic weather UIs
    @IBOutlet weak var currTempView: UILabel!
    @IBOutlet weak var currWeatherView: UILabel!
    @IBOutlet weak var currDegreeUnitView: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    @IBOutlet weak var basicWeatherSectionView: UIView!
    @IBOutlet weak var basicWeatherViewHeight: NSLayoutConstraint!
    
    // Detail weather UIs
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTepLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    
    @IBOutlet weak var detailWeatherSectionView: UIView!
    
    @IBOutlet weak var forecastWeatherCollectionView: UICollectionView!
    
    var currentCity: City!
    var forecastWeatherList: Array<ForecastWeather>?
    
    var prevContentOffset: CGFloat = 0.0
    
    let emitterLayer = CAEmitterLayer()
    let emitterCell = CAEmitterCell()
    
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
                    var highTempUnit = Measurement(value: weather.highTemp!, unit: UnitTemperature.celsius)
                    var lowTempUnit = Measurement(value: weather.lowTemp!, unit: UnitTemperature.celsius)
                    if !isMetric {
                        curTempUnit = curTempUnit.converted(to: UnitTemperature.fahrenheit)
                        highTempUnit = highTempUnit.converted(to: UnitTemperature.fahrenheit)
                        lowTempUnit = lowTempUnit.converted(to: UnitTemperature.fahrenheit)
                    }
                    self.currTempView.text = "\(Int(curTempUnit.value))"
                    self.currDegreeUnitView.text = "\(curTempUnit.unit.symbol)"
                    
                    
                    self.highTempLabel.text = "\(Int(highTempUnit.value))\(highTempUnit.unit.symbol)"
                    self.lowTepLabel.text = "\(Int(lowTempUnit.value))\(lowTempUnit.unit.symbol)"
                    
                    
                } else {
                    // Fallback on earlier versions
                    self.currTempView.text = "\(Int(round(weather.currentTemp!)))"
                    self.highTempLabel.text = "\(Int(round(weather.highTemp!)))"
                    self.lowTepLabel.text = "\(Int(round(weather.lowTemp!)))"
                }
                
                self.currWeatherView.text = city.weather?.weatherDesc
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                if let timezone = self.currentCity.timezone {
                    timeFormatter.timeZone = timezone
                }
                
                self.sunriseLabel.text = (weather.sunrize != nil) ? timeFormatter.string(from: weather.sunrize!) : "Not Available"
                self.sunsetLabel.text = (weather.sunset != nil) ? timeFormatter.string(from: weather.sunset!) : "Not Available"
                self.humidityLabel.text = (weather.humidity != nil) ? "\(weather.humidity!)%" : "Not Available"
                self.pressureLabel.text = (weather.pressure != nil) ? "\(weather.pressure!) hPa" : "Not Available"
                self.windLabel.text = (weather.windSpeed != nil && weather.windDegree != nil) ? "\(weather.windSpeed!),\(round(weather.windDegree!))" : "Not Available"
                self.cloudLabel.text = (weather.clouds != nil) ? "\(weather.clouds!)%" : "Not Available"
                
            }
            
            
            WeatherAPI.queryForecastWithCityId(city.id, units: "metric", completion: { (jsonData, error) in
                if let err = error {
                    print("ERR: \(err)")
                } else {
                    if let json = jsonData {
                        let forecastJson = JSON(json)
                        let countryCode = forecastJson["city"]["country"]
                        print(countryCode)
                        
                        
                        self.forecastWeatherList = Array()
                        
                        guard let forecastArray = forecastJson["list"].array else {return}
                        
                        for aForecastItem in forecastArray {
                            let forecastWeather = ForecastWeather()
                            forecastWeather.time = Date(timeIntervalSince1970: TimeInterval(aForecastItem["dt"].intValue))
                            forecastWeather.currentTemp = aForecastItem["main"]["temp"].doubleValue
                            forecastWeather.weatherMain = aForecastItem["weather"][0]["main"].stringValue
                            forecastWeather.precipRain = aForecastItem["rain"]["3h"].double
                            
                            self.forecastWeatherList?.append(forecastWeather)
                        }
                        
                        self.forecastCollectionView.reloadData()
                        
                    }
                }
            })
        }
        
//        setUpEmitterLayer()
//        if self.currentCity.weather?.weatherMain == "Rain" || self.currentCity.weather?.weatherMain == "Drizzle" {
//            emitterLayer.backgroundColor = kColorBackgroundRainy.cgColor
//            setUpEmitterCell()
//            
//            emitterLayer.emitterCells = [emitterCell]
//        }
//        
//        self.backgroundView.layer.addSublayer(emitterLayer)
        
        self.forecastCollectionView.register(UINib(nibName: "ForecastWeatherCell", bundle: nil), forCellWithReuseIdentifier: "forecastWeatherCell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
             print("Screen edge swiped!")
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.forecastCollectionView {
            return
        }
        
        print("content off set y is: \(scrollView.contentOffset.y)")
        
        let diffOffset = scrollView.contentOffset.y - prevContentOffset
        let yOffset = diffOffset
        
        // parallax on basic section
        basicWeatherSectionView.frame = basicWeatherSectionView.frame.offsetBy(dx: 0, dy: scrollView.contentOffset.y < 120 ? yOffset * 0.5 : yOffset)
        detailWeatherSectionView.frame = detailWeatherSectionView.frame.offsetBy(dx: 0, dy: scrollView.contentOffset.y < 130 ? 0 : yOffset)
        
        // opacity of 
        self.currWeatherView.alpha = 1 - (scrollView.contentOffset.y / (basicWeatherSectionView.frame.height / 5))
        
        prevContentOffset = scrollView.contentOffset.y
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
//                        self.updateCellBackgoundImage(named: "sunny_day")
                        let weatherLayer = ClearSkyEffectLayer(frame: self.backgroundView.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Rain", "Drizzle":
                        //self.updateCellBackgoundImage(named: "rainy_day")
                        let weatherLayer = RainEffectLayer(frame: self.backgroundView.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        addRainyClouds()
                        break

                        
                    case "Snow":
                        self.updateCellBackgoundImage(named: "snowy_day")
                        break
                        
                    case "Clouds":
                        //self.updateCellBackgoundImage(named: "cloudy_day")
                        let weatherLayer = CloudEffectLayer(frame: self.backgroundView.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        addOvercastClouds()
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
                        //self.updateCellBackgoundImage(named: "sunny_night")
                        let weatherLayer = ClearSkyEffectLayer(frame: self.backgroundView.frame, dayNight: .night)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        break
                        
                    case "Rain", "Drizzle":
                        //self.updateCellBackgoundImage(named: "rainy_day")
                        let weatherLayer = RainEffectLayer(frame: self.backgroundView.frame, dayNight: .night)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        addRainyClouds()
                        break
                        
                    case "Snow":
                        self.updateCellBackgoundImage(named: "snowy_night")
                        break
                        
                    case "Clouds":
                        //self.updateCellBackgoundImage(named: "cloudy_day")
                        let weatherLayer = CloudEffectLayer(frame: self.backgroundView.frame, dayNight: .night)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        addOvercastClouds()
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
    
    private func addRainyClouds() {
        let cloudImage = UIImageView(frame: CGRect(x: 10, y: 10, width: 300, height: 200))
        cloudImage.alpha = 0.3
        cloudImage.image = UIImage(named: "cloud_rain_2")
        self.basicWeatherSectionView.addSubview(cloudImage)
        self.basicWeatherSectionView.sendSubview(toBack: cloudImage)
        
        UIView.animate(withDuration: 45, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveEaseInOut], animations: {
            cloudImage.center.x += 200
        }, completion: nil)
        
        
        let cloudImage2 = UIImageView(frame: CGRect(x: 150, y: 10, width: 220, height: 160))
        cloudImage2.alpha = 0.2
        cloudImage2.image = UIImage(named: "cloud_rain_1")
        self.basicWeatherSectionView.addSubview(cloudImage2)
        self.basicWeatherSectionView.sendSubview(toBack: cloudImage2)
        
        UIView.animate(withDuration: 50, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveLinear], animations: {
            cloudImage2.center.x -= 200
        }, completion: nil)
        
    }
    
    private func addOvercastClouds() {
        let cloudImage = UIImageView(frame: CGRect(x: 10, y: 10, width: 300, height: 200))
        cloudImage.alpha = 0.3
        cloudImage.image = UIImage(named: "cloud_clear_1")
        self.basicWeatherSectionView.addSubview(cloudImage)
        self.basicWeatherSectionView.sendSubview(toBack: cloudImage)
        
        UIView.animate(withDuration: 45, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveEaseInOut], animations: {
            cloudImage.center.x += 200
        }, completion: nil)
        
        
        let cloudImage2 = UIImageView(frame: CGRect(x: 150, y: 10, width: 220, height: 160))
        cloudImage2.alpha = 0.2
        cloudImage2.image = UIImage(named: "cloud_clear_1")
        self.basicWeatherSectionView.addSubview(cloudImage2)
        self.basicWeatherSectionView.sendSubview(toBack: cloudImage2)
        
        UIView.animate(withDuration: 50, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveLinear], animations: {
            cloudImage2.center.x -= 200
        }, completion: nil)
    }
    
    private func updateCellBackgoundImage(named: String) {
        //self.backgroundView.image = UIImage(named: named)
    }
    
    func setUpEmitterLayer() {
        emitterLayer.frame = self.view.bounds
        emitterLayer.seed = UInt32(NSDate().timeIntervalSince1970)
        emitterLayer.renderMode = kCAEmitterLayerAdditive
        emitterLayer.drawsAsynchronously = true
        
        if isDayTime(date: Date()) {
            emitterLayer.backgroundColor = kColorBackgroundDay.cgColor
        } else {
            emitterLayer.backgroundColor = kColorBackgroundNight.cgColor
        }
        
        setEmitterPosition()
    }
    
    // 3
    func setUpEmitterCell() {
        emitterCell.contents = UIImage(named: "particle_rain")?.cgImage
        
        emitterCell.lifetime = 3.0
        emitterCell.birthRate = 100.0
        
        emitterCell.velocity = 1600.0
        emitterCell.velocityRange = 100.0
        
        emitterCell.emissionLatitude = degreesToRadians(271)
        emitterCell.emissionLongitude = degreesToRadians(300)
        emitterCell.emissionRange = degreesToRadians(0)
        
        emitterCell.xAcceleration = -50
        emitterCell.yAcceleration = 1000
        emitterCell.zAcceleration = 0
        
        emitterCell.alphaRange = 0.2
        emitterCell.scale = 0.15
        
        emitterCell.color = UIColor.gray.cgColor
        emitterCell.redRange = 0.0
        emitterCell.greenRange = 0.0
        emitterCell.blueRange = 0.0
        emitterCell.alphaRange = 0.0
        emitterCell.redSpeed = 0.0
        emitterCell.greenSpeed = 0.0
        emitterCell.blueSpeed = 0.0
        emitterCell.alphaSpeed = 0

    }
    
    func degreesToRadians(_ degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
    
    func setEmitterPosition() {
        emitterLayer.emitterPosition = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.minY - 50)
        emitterLayer.emitterSize = CGSize(width: self.backgroundView.bounds.width * 1.2, height: 5)
        emitterLayer.emitterShape = kCAEmitterLayerLine;
    }
    
    func isDayTime(date: Date) -> Bool {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H"
        if let timezone = self.currentCity.timezone {
            timeFormatter.timeZone = timezone
        }
        let hourString = timeFormatter.string(from: date)
        
        return Int(hourString)! >= 6 && Int(hourString)! < 18
    }
}

extension CityWeatherDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.forecastWeatherList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "forecastWeatherCell", for: indexPath) as! ForecastWeatherCell
        
        guard let forecastList = self.forecastWeatherList else {
            return cell
        }
        cell.city = self.currentCity
        cell.forecastWeather = forecastList[indexPath.row]
        
        cell.updateCell()
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h a"
        if let timezone = self.currentCity.timezone {
            timeFormatter.timeZone = timezone
        }
        
        if isDayTime(date: forecastList[indexPath.row].time!) {
            cell.containerView.backgroundColor = kColorForecastDay
        } else {
            cell.containerView.backgroundColor = kColorForecastNight
        }
        
        cell.timeLabel.text = timeFormatter.string(from: forecastList[indexPath.row].time!)
        cell.weatherLabel.text = forecastList[indexPath.row].weatherMain ?? "unavailable"
        cell.tempLabel.text = "\(forecastList[indexPath.row].currentTemp!)"
        
        if let rainPrecip = forecastList[indexPath.row].precipRain {
            cell.precipLabel.text = rainPrecip > 1 ? "\(round(rainPrecip))mm" : "<1mm"
        } else {
            cell.precipLabel.text = "0mm"
        }
        
        if #available(iOS 10.0, *) {
            let isMetric = UserDefaults.standard.bool(forKey: "isMetric")
            
            var curTempUnit = Measurement(value: forecastList[indexPath.row].currentTemp!, unit: UnitTemperature.celsius)

            if !isMetric {
                curTempUnit = curTempUnit.converted(to: UnitTemperature.fahrenheit)
            }
            
             cell.tempLabel.text = "\(Int(curTempUnit.value))\(curTempUnit.unit.symbol)"
            
        } else {
            // Fallback on earlier versions
            cell.tempLabel.text = "\(forecastList[indexPath.row].currentTemp!)"
        }

        
        cell.weatherImageView.image = cell.weatherImageView.image?.maskWithColor(color: UIColor.white)
        cell.precipImageView.image = cell.precipImageView.image?.maskWithColor(color: UIColor.white)
        return cell
    }
}
