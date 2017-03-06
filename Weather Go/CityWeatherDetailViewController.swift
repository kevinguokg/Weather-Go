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
import GoogleMobileAds

class CityWeatherDetailViewController: UIViewController, UIScrollViewDelegate {
    // General UIs
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIImageView!
    
    // Basic weather UIs
    @IBOutlet weak var cityNameLabel: UILabel!
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
    
    // Ad section
    
    @IBOutlet weak var adBannerView: GADBannerView!
    
    var currentCity: City!
    var forecastWeatherList: Array<ForecastWeather>?
    
    var prevContentOffset: CGFloat = 0.0
    
    let emitterLayer = CAEmitterLayer()
    let emitterCell = CAEmitterCell()
    
    var animationLayer: [CALayer]? = nil
    
    // need to understand how constructor works
//    convenience init(city: City) {
//        self.init()
//        self.currentCity = city
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.layoutIfNeeded()
        
        adBannerView.adSize = kGADAdSizeSmartBannerPortrait
        adBannerView.adUnitID = kAdMobBannerUnitId
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        adBannerView.load(GADRequest())
        
        let panEdgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        panEdgeGesture.edges = .left
        self.view.addGestureRecognizer(panEdgeGesture)
        
        if let city = self.currentCity {
            self.title = city.name
            cityNameLabel.text = city.name
            
            if let weather = city.weather {
                
                self.setBackgroundImageForCity(city: city)
                let isMetric = UserDefaults.standard.bool(forKey: "isMetric")
                if #available(iOS 10.0, *) {
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
                    
                    
                    
                    var curSpeedUnit = Measurement(value: city.weather!.windSpeed!, unit: UnitSpeed.metersPerSecond)
                    
                    if !isMetric {
                        curSpeedUnit = curSpeedUnit.converted(to: UnitSpeed.milesPerHour)
                    }
                    
                    self.windLabel.text = (weather.windSpeed != nil && weather.windDegree != nil) ? "\(Int(curSpeedUnit.value)) \(curSpeedUnit.unit.symbol) \(weather.degreeToString(degree: weather.windDegree)!)" : "Not Available"
                    
                } else {
                    // Fallback on earlier versions
                    var temperatureUnitSymol = kTempUnitSymbolMetric
                    var windSpeedUnitSymbol  = kWindSpeedUnitSymbolMetric
                    
                    if !isMetric {
                        temperatureUnitSymol = kTempUnitSymbolEngish
                        windSpeedUnitSymbol  = kWindSpeedUnitSymbolEnglish
                    }
                    
                    self.currTempView.text = "\(Int(round(weather.currentTemp!)))\(temperatureUnitSymol)"
                    self.highTempLabel.text = "\(Int(round(weather.highTemp!)))\(temperatureUnitSymol)"
                    self.lowTepLabel.text = "\(Int(round(weather.lowTemp!)))\(temperatureUnitSymol)"
                    
                    self.windLabel.text = (weather.windSpeed != nil && weather.windDegree != nil) ? "\(weather.windSpeed!) \(windSpeedUnitSymbol) \(weather.degreeToString(degree: weather.windDegree)!)" : "Not Available"
                }
                
                self.currWeatherView.text = city.weather?.weatherDesc?.capitalized
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "h:mm a"
                if let timezone = self.currentCity.timezone {
                    timeFormatter.timeZone = timezone
                }
                
                self.sunriseLabel.text = (weather.sunrize != nil) ? timeFormatter.string(from: weather.sunrize!) : "Not Available"
                self.sunsetLabel.text = (weather.sunset != nil) ? timeFormatter.string(from: weather.sunset!) : "Not Available"
                self.humidityLabel.text = (weather.humidity != nil) ? "\(Int(weather.humidity!))%" : "Not Available"
                self.pressureLabel.text = (weather.pressure != nil) ? "\(Int(weather.pressure!)) hPa" : "Not Available"
                self.cloudLabel.text = (weather.clouds != nil) ? "\(Int(weather.clouds!))%" : "Not Available"
                
            }
            
            
            WeatherAPI.queryForecastWithCityId(city.id, units: "metric", completion: { (jsonData, error) in
                if let err = error {
                    print("ERR: \(err)")
                } else {
                    if let json = jsonData {
                        let forecastJson = JSON(json)
                        let countryCode = forecastJson["city"]["country"]
                        print(countryCode)
                        
                        
                        self.forecastWeatherList = Array<ForecastWeather>()
                        
                        guard let forecastArray = forecastJson["list"].array else {return}
                        
                        for aForecastItem in forecastArray {
                            let forecastWeather = ForecastWeather()
                            forecastWeather.time = Date(timeIntervalSince1970: TimeInterval(aForecastItem["dt"].intValue))
                            forecastWeather.currentTemp = aForecastItem["main"]["temp"].doubleValue
                            forecastWeather.weatherMain = aForecastItem["weather"][0]["main"].stringValue
                            forecastWeather.precipRain = aForecastItem["rain"]["3h"].double
                            forecastWeather.precipSnow = aForecastItem["snow"]["3h"].double
                            
                            self.forecastWeatherList?.append(forecastWeather)
                        }
                        
                        self.currentCity.forecast = self.forecastWeatherList
                        
                        self.forecastCollectionView.alpha = 0.0
                        self.forecastCollectionView.isHidden = false
                        
                        self.forecastCollectionView.reloadData()
                        
                        UIView.animate(withDuration: 0.5, animations: { 
                            self.forecastCollectionView.alpha = 1.0
                        }, completion: { (finished) in
                            self.forecastCollectionView.isHidden = false
                        })
                        
                        //UserDefaultManager.addTheCityToUserDefault(city: self.currentCity)
                    }
                }
            })
        }
        
        self.forecastCollectionView.register(UINib(nibName: "ForecastWeatherCell", bundle: nil), forCellWithReuseIdentifier: "forecastWeatherCell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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

    // MARK: Weather effect methods
    private func setBackgroundImageForCity(city: City) {
        let date = Date()
        // determine sunrise
        if let sunrise = city.weather?.sunrize, let sunset = city.weather?.sunset {
            if sunrise < date && date < sunset {
                // sunrise...
                if let weatherType = city.weather?.weatherMain {
                    switch weatherType {
                    case "Clear":
                        let weatherLayer = ClearSkyEffectLayer(frame: self.view.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer, weatherLayer.createSunLightLayer()]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        break
                        
                    case "Rain", "Drizzle":
                        let weatherLayer = RainEffectLayer(frame: self.view.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        addRainyClouds()
                        break

                    case "Thunderstorm":
                        let weatherLayer = ThunderEffectLayer(frame: self.view.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        addLightning()
                        addRainyClouds()
                        break
                        
                    case "Snow":
                        let weatherLayer = SnowEffectLayer(frame: self.view.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        break
                        
                    case "Clouds":
                        let weatherLayer = CloudEffectLayer(frame: self.view.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        addOvercastClouds()
                        break
                        
                    case "Fog", "Mist", "Haze":
                        let weatherLayer = FogEffectLayer(frame: self.view.frame, dayNight: .day)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
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
                        let weatherLayer = ClearSkyEffectLayer(frame: self.view.frame, dayNight: .night, displayType: .full)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        break
                        
                    case "Rain", "Drizzle":
                        let weatherLayer = RainEffectLayer(frame: self.view.frame, dayNight: .night)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        addRainyClouds()
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        break
                        
                    case "Thunderstorm":
                        let weatherLayer = ThunderEffectLayer(frame: self.view.frame, dayNight: .night)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        addLightning()
                        addRainyClouds()
                        break
                        
                    case "Snow":
                        let weatherLayer = SnowEffectLayer(frame: self.view.frame, dayNight: .night)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        break
                        
                    case "Clouds":
                        let weatherLayer = CloudEffectLayer(frame: self.view.frame, dayNight: .night)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
                        addOvercastClouds()
                        break
                        
                    case "Fog", "Mist", "Haze":
                        let weatherLayer = FogEffectLayer(frame: self.view.frame, dayNight: .night)
                        self.backgroundView?.layer.sublayers = [weatherLayer.emitterLayer]
                        self.view.backgroundColor =  UIColor(cgColor: weatherLayer.emitterLayer.backgroundColor!)
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
        
        let weatherLayer = ThunderEffectLayer(frame: self.view.frame, dayNight: .day)
        
        // bolt layer
        let boltLayer = weatherLayer.addBoltWith(startPoint: CGPoint(x: self.view.frame.width / 2, y: 0.0), endPoint: CGPoint(x: self.view.frame.width / 3.0, y: self.view.frame.height))
        self.animationLayer = Array()
        
        self.animationLayer?.append(boltLayer)
        self.backgroundView?.layer.addSublayer(boltLayer)
        
        // flashing light layer
        let lightLayer = weatherLayer.addLightning()
        self.animationLayer?.append(lightLayer)
        self.backgroundView?.layer.addSublayer(lightLayer)
    }
    
    private func addLightning() {
        if #available(iOS 10.0, *) {
            _ = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { (timer) in
                self.lightningAnimation()
            }
        } else {
            // Fallback on earlier versions
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(lightningAnimation), userInfo: nil, repeats: true)
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
    
    private func addFogClouds() {
        let cloudImage = UIImageView(frame: CGRect(x: 10, y: 10, width: 300, height: 200))
        cloudImage.alpha = 0.8
        cloudImage.image = UIImage(named: "cloud_fog")
        self.basicWeatherSectionView.addSubview(cloudImage)
        self.basicWeatherSectionView.sendSubview(toBack: cloudImage)
        
        UIView.animate(withDuration: 45, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveEaseInOut], animations: {
            cloudImage.center.x += 200
        }, completion: nil)
        
        
        let cloudImage2 = UIImageView(frame: CGRect(x: 200, y: 10, width: 220, height: 160))
        cloudImage2.alpha = 0.6
        cloudImage2.image = UIImage(named: "cloud_fog")
        self.basicWeatherSectionView.addSubview(cloudImage2)
        self.basicWeatherSectionView.sendSubview(toBack: cloudImage2)
        
        UIView.animate(withDuration: 50, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveLinear], animations: {
            cloudImage2.center.x -= 200
        }, completion: nil)
    }
    
    private func addSumBeam() {
        let sunLayer = CAShapeLayer()
        sunLayer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 100, height: 100)).cgPath
        
        sunLayer.fillColor = kColorSunLight.cgColor
        sunLayer.lineWidth = 0
        self.basicWeatherSectionView.layer.addSublayer(sunLayer)
        
        let cloudImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        cloudImage.clipsToBounds = true
        cloudImage.contentMode = .scaleAspectFill
        
        cloudImage.alpha = 0
        cloudImage.image = UIImage(named: "sun_beam")
        //self.basicWeatherSectionView.addSubview(cloudImage)
        //self.basicWeatherSectionView.sendSubview(toBack: cloudImage)
        
//        UIView.animate(withDuration: 20, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat, .curveEaseInOut], animations: {
//            cloudImage.alpha = 0.9
//            cloudImage.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
//        }, completion: nil)
        
        
        
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

extension CityWeatherDetailViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Did received ad")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Error in receiving ad: \(error.localizedDescription)")
    }
}

extension CityWeatherDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        timeFormatter.dateFormat = "E"
        cell.dayLabel.text = timeFormatter.string(from: forecastList[indexPath.row].time!)
        cell.weatherLabel.text = forecastList[indexPath.row].weatherMain ?? "unavailable"
        cell.tempLabel.text = "\(forecastList[indexPath.row].currentTemp!)"
        
        if let rainPrecip = forecastList[indexPath.row].precipRain {
            cell.precipImageView.image = UIImage(named: "icon_precip_rainy")
            cell.precipLabel.text = rainPrecip > 1 ? "\(Int(round(rainPrecip)))mm" : "<1mm"
        } else {
            cell.precipLabel.text = "0mm"
        }
        
        if let snowPrecip = forecastList[indexPath.row].precipSnow {
            cell.precipImageView.image = UIImage(named: "icon_snow")
            cell.precipLabel.text = snowPrecip > 1 ? "\(Int(round(snowPrecip)))mm" : "<1mm"
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
