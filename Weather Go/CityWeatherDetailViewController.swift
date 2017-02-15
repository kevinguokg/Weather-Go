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
                            
                            self.forecastWeatherList?.append(forecastWeather)
                        }
                        
                        self.forecastCollectionView.reloadData()
                        
                    }
                }
            })
        }
        
        setUpEmitterLayer()
        setUpEmitterCell()
        emitterLayer.emitterCells = [emitterCell]
        self.backgroundView.layer.addSublayer(emitterLayer)
        
        self.forecastCollectionView.register(UINib(nibName: "ForecastWeatherCell", bundle: nil), forCellWithReuseIdentifier: "forecastWeatherCell")
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.forecastCollectionView {
            return
        }
        
        print("content off set y is: \(scrollView.contentOffset.y)")
        
        let diffOffset = scrollView.contentOffset.y - prevContentOffset
        let yOffset = diffOffset
        
        // parallax on basic section
        basicWeatherSectionView.frame = basicWeatherSectionView.frame.offsetBy(dx: 0, dy: scrollView.contentOffset.y < 120 ? yOffset * 0.6 : yOffset)
        
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
        //self.backgroundView.image = UIImage(named: named)
    }
    
    func setUpEmitterLayer() {
        emitterLayer.frame = self.view.bounds
        emitterLayer.seed = UInt32(NSDate().timeIntervalSince1970)
        emitterLayer.renderMode = kCAEmitterLayerAdditive
        emitterLayer.drawsAsynchronously = true
        emitterLayer.backgroundColor = UIColor.init(colorLiteralRed: 117/255, green: 117/255, blue: 163/255, alpha: 0.8).cgColor
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
        
        //let cell = Bundle.main.loadNibNamed("ForecastWeatherCell", owner: self, options: nil)?.first as! ForecastWeatherCell
        
        guard let forecastList = self.forecastWeatherList else {
            return cell
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h a"
        cell.timeLabel.text = timeFormatter.string(from: forecastList[indexPath.row].time!)
        cell.weatherLabel.text = forecastList[indexPath.row].weatherMain ?? "unavailable"
        cell.weatherImageView.image = UIImage(named: "icon_partly_cloudy")
        cell.tempLabel.text = "\(forecastList[indexPath.row].currentTemp!)"
        
        cell.weatherImageView.image = cell.weatherImageView.image?.maskWithColor(color: UIColor.white)
        cell.precipImageView.image = cell.precipImageView.image?.maskWithColor(color: UIColor.white)
        return cell
    }
}
