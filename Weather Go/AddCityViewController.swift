//
//  AddCityViewController.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-18.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class AddCityViewController : UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //let searchController = UISearchController(searchResultsController: nil)
    var cityList: Array<City>?
    var selectedCity: City?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //cityList = ["Shanghai", "Vancouver"]
        cityList = Array()
        
        searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Searchbar Delegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchBar.text ?? "")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // ask for city
        WeatherAPI.queryWeatherWithCityName(searchBar.text!, units: "metric", countryCode: "") { (json, err) in
            if err == nil {
                if let json = json {
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
                        
                    print(city)
                    self.cityList?.append(city)
                    self.tableView.reloadData()
                }
            } else {
                
                print("ERR: \(err)")
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        cell.textLabel?.text = (cityList?[indexPath.row])?.name
        cell.detailTextLabel?.text = (cityList?[indexPath.row])?.weather?.weatherDesc ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let city = self.cityList?[indexPath.row] {
            self.selectedCity = city
            self.performSegue(withIdentifier: "CitySelectedSegue", sender: self)
        }
    }
    
    
}
