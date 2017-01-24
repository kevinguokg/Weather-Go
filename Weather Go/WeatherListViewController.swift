//
//  WeatherListViewController.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-18.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class WeatherListViewController : UITableViewController {
    
    var citiList : Array<City>?
    var selectedCity: City?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let defaults = UserDefaults.standard
        citiList = Array()
        if let citiArr = defaults.object(forKey: "cityList") as? NSMutableArray{
            for cityData in citiArr {
                citiList?.append(NSKeyedUnarchiver.unarchiveObject(with: cityData as! Data) as! City)
            }
        }
        
        if let isEmpty = citiList?.isEmpty, isEmpty == false {
            // query cached city
            for city in citiList! {
                WeatherAPI.queryWeatherWithCityId(city.id, units: "metric", completion: { (jsonData, error) in
                    if let err = error {
                        print("error.. \(err)")
                    } else {
                        if let json = jsonData {
                            
                            let cityJson = JSON(json)
                            let city = City(id: "\(cityJson["id"].intValue)", name: cityJson["name"].stringValue, latitude: cityJson["coord"]["lat"].doubleValue, longitude: cityJson["coord"]["lon"].doubleValue)
                            
                            let weather = Weather()
                            weather.weatherDesc = cityJson["weather"][0]["description"].stringValue
                            weather.currentTemp = cityJson["main"]["temp"].doubleValue
                            weather.highTemp = cityJson["main"]["temp_max"].doubleValue
                            weather.lowTemp = cityJson["main"]["temp_min"].doubleValue
                            weather.humidity = cityJson["main"]["humidity"].doubleValue
                            weather.pressure = cityJson["main"]["pressure"].doubleValue
                            weather.windSpeed = cityJson["wind"]["speed"].doubleValue
                            weather.windDegree = cityJson["wind"]["deg"].doubleValue
                            weather.sunrize =  Date(timeIntervalSince1970: TimeInterval(cityJson["sys"]["sunrise"].intValue))
                            weather.sunset =  Date(timeIntervalSince1970: TimeInterval(cityJson["sys"]["sunset"].intValue))
                            city.weather = weather
                            
                            for (index, thisCity) in (self.citiList?.enumerated())! {
                                if thisCity.id == city.id {
                                    self.citiList?[index] = city
                                }
                            }
                            print("City: \(city.name) has been updated.")
                            self.tableView.reloadData()
                        }
                    }
                })
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindFromAddCityListPage(sender: UIStoryboardSegue)
    {
        
        if sender.identifier == "CitySelectedSegue" {
            let sourceViewController = (sender.source) as! AddCityViewController
            if let selectedCity = sourceViewController.selectedCity {
                citiList?.append(selectedCity)
                self.tableView.reloadData()
                
                // add city to user defaults
                let defaults = UserDefaults.standard
                let archivedArray: NSMutableArray = NSMutableArray()
                for city in citiList! {
                    let data = NSKeyedArchiver.archivedData(withRootObject: city)
                    archivedArray.add(data)
                }
                defaults.set(archivedArray, forKey: "cityList")
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.citiList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityWeatherCell", for: indexPath)
        
        cell.textLabel?.text = citiList?[indexPath.row].name
        if let city = citiList?[indexPath.row]{
            if #available(iOS 10.0, *) {
                //let curTempKalvin = Measurement(value: city.weather!.currentTemp!, unit: UnitTemperature.kelvin)
                //let curTempCel = curTempKalvin.converted(to: UnitTemperature.celsius)
                
                let curTempCel = Measurement(value: city.weather!.currentTemp!, unit: UnitTemperature.celsius)
                //let formatter = MeasurementFormatter()
                //let string = formatter.string(from: curTempCel)
                //let string2 = formatter.string(from: UnitTemperature.celsius)
                //print(string2)
                cell.detailTextLabel?.text = "\(curTempCel.value)\(curTempCel.unit.symbol)"
            } else {
                // Fallback on earlier versions
                cell.detailTextLabel?.text = "\((city.weather?.currentTemp!)!)"
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCity = self.citiList?[indexPath.row]
        performSegue(withIdentifier: "showCityDetail", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "showCityDetail" {
            let weatherDetailVc = segue.destination as! CityWeatherDetailViewController
            if let city = self.selectedCity {
                weatherDetailVc.currentCity = city
            }
            
        }
    }
    
    
    
}

