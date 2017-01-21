//
//  WeatherListViewController.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-01-18.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class WeatherListViewController : UITableViewController {
    
    var citiList : Array<City>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        citiList = Array()
        

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
                let curTempKalvin = Measurement(value: city.weather!.currentTemp!, unit: UnitTemperature.kelvin)
                let curTempCel = curTempKalvin.converted(to: UnitTemperature.celsius)
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
    
    
    
    
}

