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
import CoreLocation

class AddCityViewController : UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //let searchController = UISearchController(searchResultsController: nil)
    var cityList: Array<City>?
    var selectedCity: City?
    
    lazy var locationManager: CLLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        cityList = Array()
        
        locationManager.delegate = self
        
        searchBar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getQuickLocationUpdate() {
        // Request location authorization
        self.locationManager.requestWhenInUseAuthorization()
        
        // Request a location update
        self.locationManager.requestLocation()
        // Note: requestLocation may timeout and produce an error if authorization has not yet been granted by the user
    }
    
    // MARK: Location Manager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Process the received location update
        print(locations)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        WeatherAPI.queryWeatherWithLocation(locations[0], units: "metric") { (json, error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error == nil {
                if let json = json {
                    if let city = self.parseCityJson(json) {
                        self.addCityToList(city)
                    }
                }
            } else {
                print("ERR: \(error)")
            }
        }
        
        // Stop location updates
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // MARK: Searchbar Delegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // ask for city
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        WeatherAPI.queryWeatherWithCityName(searchBar.text!, units: "metric", countryCode: "") { (json, err) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if err == nil {
                if let json = json {
                    if let city = self.parseCityJson(json) {
                        self.addCityToList(city)
                    }
                }
            } else {
                print("ERR: \(err)")
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func parseCityJson(_ json: Any) -> City? {
        let cityJson = JSON(json)
        let city = City(id: "\(cityJson["id"].intValue)", name: cityJson["name"].stringValue, latitude: cityJson["coord"]["lat"].doubleValue, longitude: cityJson["coord"]["lon"].doubleValue, countryCode: cityJson["sys"]["country"].stringValue)
        
        let weather = Weather()
        weather.weatherMain = cityJson["weather"][0]["main"].stringValue
        weather.weatherDesc = cityJson["weather"][0]["description"].stringValue
        weather.currentTemp = cityJson["main"]["temp"].doubleValue
        weather.highTemp = cityJson["main"]["temp_max"].doubleValue
        weather.lowTemp = cityJson["main"]["temp_min"].doubleValue
        weather.humidity = cityJson["main"]["humidity"].doubleValue
        weather.pressure = cityJson["main"]["pressure"].doubleValue
        weather.windSpeed = cityJson["wind"]["speed"].doubleValue
        weather.windDegree = cityJson["wind"]["deg"].doubleValue
        weather.clouds = cityJson["clouds"]["all"].doubleValue
        weather.sunrize =  Date(timeIntervalSince1970: TimeInterval(cityJson["sys"]["sunrise"].intValue))
        weather.sunset =  Date(timeIntervalSince1970: TimeInterval(cityJson["sys"]["sunset"].intValue))
        city.weather = weather
        
        #if DEBUG
            print(city)
        #endif
        
        return city
    }
    
    private func addCityToList(_ city: City) {
        if let contains = self.cityList?.contains(where: { $0.id == city.id }), !contains {
            self.cityList?.append(city)
            self.tableView.reloadData()
        }
    }
    
    // MARK: UITableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return cityList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Add Current Location"
            cell.textLabel?.textColor = UIColor.blue
            break
            
        case 1:
            cell.textLabel?.text = (cityList?[indexPath.row])?.name
            cell.detailTextLabel?.text = (cityList?[indexPath.row])?.weather?.weatherDesc ?? ""
            break
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // detect current location..
            self.getQuickLocationUpdate()
            break
        case 1:
            if let city = self.cityList?[indexPath.row] {
                self.selectedCity = city
                self.searchBar.resignFirstResponder()
                self.performSegue(withIdentifier: "CitySelectedSegue", sender: self)
            }
            break
        default:
            break;
        }
        
        
        
    }
    
    
}
