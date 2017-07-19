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
import CoreLocation
import TimeZoneLocate
import RainyRefreshControl

class WeatherListViewController : UITableViewController, UIViewControllerPreviewingDelegate {
    
    @IBAction func degreeBtnTapped(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isMetric") == true {
            return
        }
        
        UserDefaults.standard.set(true, forKey: "isMetric")
        UserDefaults.standard.synchronize()
        self.tableView.reloadData()
    }
    
    
    @IBAction func feirenheihtBtnTapped(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isMetric") == false {
            return
        }
        
        UserDefaults.standard.set(false, forKey: "isMetric")
        UserDefaults.standard.synchronize()
        self.tableView.reloadData()
    }
    
    var citiList : Array<City>?
    var selectedCity: City?
    
    var timer: Timer = Timer()
    
    struct Cell {
        static var snapShot: UIView? = nil
    }
    
    struct Path {
        static var initialIndexPath: IndexPath? = nil
    }
    
    struct CityList {
        static var cityList: Array<City>? = nil
    }
    
    var openingFrame: CGRect?
    
    let panGestureInteractor: Interactor = Interactor()
    let navTransitionAnimator:NavigationTransitionAnimator = NavigationTransitionAnimator()
    
    let modalDismissAnimator: ModalDismissAnimator = ModalDismissAnimator()
    
    let refresh = RainyRefreshControl()
    
    var blurView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = UIImage(named: "sunny_night") {
            // create a background view
            let backgroundView = UIView()
            backgroundView.frame = self.tableView.bounds
            
            // adds image view to background view
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            imageView.frame = self.tableView.bounds
            backgroundView.addSubview(imageView)
            
            // adds blurView to backgrond view for blur effect
            blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
            blurView?.frame = self.tableView.bounds
            backgroundView.addSubview(blurView!)
            
            // set tableView's backgroundView
            self.tableView.backgroundView = backgroundView
        }
        
        self.navigationController?.delegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime) , userInfo: nil, repeats: true)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        self.tableView.addGestureRecognizer(longPress)
        
        refresh.addTarget(self, action: #selector(doRefresh), for: .valueChanged)
        tableView.addSubview(refresh)
        
        let defaults = UserDefaults.standard
        citiList = Array()
        if let citiArr = defaults.object(forKey: "cityList") as? Array<Any>{
            for cityData in citiArr {
                if let theCity = NSKeyedUnarchiver.unarchiveObject(with:cityData as! Data) as? City {
                    theCity.needsUpdate = true
                    citiList?.append(theCity)
                }
            }
        }
        
        self.tableView.reloadData()
        
        // only register force touch if it is available for the device
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: self.tableView)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(openAddCityVc), name: Notification.Name.quickActionOpenAddCityVc, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveCachedWeatherList), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(minimizeView(_:)), name: Notification.Name.minimizeViewController, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(maximizeView(_:)), name: Notification.Name.maximizeViewController, object: nil)
        
        if let delegate =  UIApplication.shared.delegate as? AppDelegate{
            delegate.triggerShortcutItem()
        }
    }
    
    func setNeedsUpdateFlagForAllCities() {
        if let cityList = self.citiList {
            for city in cityList {
                city.needsUpdate = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.quickActionOpenAddCityVc, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.minimizeViewController, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.maximizeViewController, object: nil)
    }
    
    func saveCachedWeatherList() {
        // add city to user defaults
        UserDefaultManager.addCityToUserDefault(self.citiList!, withKey: "cityList")
    }
    
    @IBAction func unwindFromAddCityListPage(sender: UIStoryboardSegue)
    {
        
        if sender.identifier == "CitySelectedSegue" {
            let sourceViewController = (sender.source) as! AddCityViewController
            if let selectedCity = sourceViewController.selectedCity {
                self.addCityToList(selectedCity)
                // add city to user defaults
                UserDefaultManager.addCityToUserDefault(self.citiList!, withKey: "cityList")
            }
        }
    }
    
    func doRefresh() {
        impactHapticFeedback(style: .medium)
        setNeedsUpdateFlagForAllCities()
        self.tableView.reloadData()
    }
    
    private func addCityToList(_ city: City) {
        if let contains = self.citiList?.contains(where: { $0.id == city.id }), !contains {
            citiList?.append(city)
            self.tableView.reloadData()
        }
    }
    
    func updateTime() {
        for cell in self.tableView.visibleCells as! [CityWeatherCell]{
            cell.updateCellTime()
        }
        
        // temprary turn off lastUpdatedDate
        //self.refresh.updateLastUpdatedTime(date: Date())
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longPress.state
        
        // finds the according index path based on gestrue performed on tableView
        let locationInView = longPress.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: locationInView)
        
        switch state {
            case .began:
                if let indexPath = indexPath {
                    CityList.cityList = self.citiList!
                    Path.initialIndexPath = indexPath
                    let cell = self.tableView.cellForRow(at: indexPath) as! CityWeatherCell
                    Cell.snapShot = snapshotOfCell(cell)
                    var center = cell.center
                    Cell.snapShot?.center = center
                    Cell.snapShot?.alpha = 0.0
                    self.tableView.addSubview(Cell.snapShot!)
                    
                    UIView.animate(withDuration: 0.25, animations: { 
                        center.y = locationInView.y
                        Cell.snapShot?.center = center
                        Cell.snapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        Cell.snapShot?.alpha = 0.98
                        cell.alpha = 0.0
                    }, completion: { (completed) in
                        if completed {
                            cell.isHidden = true
                        }
                    })
                    
                    impactHapticFeedback(style: UIImpactFeedbackStyle.medium)
                    
                }
                break
                
            case .changed:
                if let cachedCellCenter = Cell.snapShot?.center {
                    
                    var center = cachedCellCenter
                    center.y = locationInView.y
                    Cell.snapShot?.center = center
                    
                    if let indexPath = indexPath, indexPath != Path.initialIndexPath {
                        swap(&self.citiList![indexPath.row], &self.citiList![(Path.initialIndexPath?.row)!])
                        self.tableView.moveRow(at: Path.initialIndexPath!, to: indexPath)
                        Path.initialIndexPath = indexPath
                        selectionHapticFeedback()
                    }
                }
                
                break

            default:
                if let indexPath = indexPath {
                    let cell = self.tableView.cellForRow(at: indexPath) as! CityWeatherCell
                    cell.isHidden = false
                    cell.alpha = 0.0
                    UIView.animate(withDuration: 0.25, animations: { 
                        Cell.snapShot?.center = cell.center
                        Cell.snapShot?.transform = CGAffineTransform.identity
                        Cell.snapShot?.alpha = 0.0
                        
                        cell.alpha = 1.0
                    }, completion: { (completed) in
                        if completed {
                            Path.initialIndexPath = nil
                            Cell.snapShot?.removeFromSuperview()
                            Cell.snapShot = nil
                            
                            if CityList.cityList! != self.citiList! {
                                UserDefaultManager.addCityToUserDefault(self.citiList!, withKey: "cityList")
                            }
                            
                            CityList.cityList = nil
                        }
                    })
                    
                    impactHapticFeedback(style: UIImpactFeedbackStyle.medium)
                    
                }
                
                break
        }
        
    }
    
    private func impactHapticFeedback(style: UIImpactFeedbackStyle){
        // haptic feedback (now only on iOS 10+)
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
        }
    }
    
    private func selectionHapticFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    private func snapshotOfCell(_ view: UIView) -> UIView? {
        var cellSnapshot: UIView? = view.resizableSnapshotView(from: view.bounds, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
        if let cellSnapshot = cellSnapshot {
            cellSnapshot.layer.masksToBounds = false
            cellSnapshot.layer.cornerRadius = 0.0
            cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 5.0)
            cellSnapshot.layer.shadowRadius = 5.0
            cellSnapshot.layer.shadowOpacity = 0.4
        } else {
            let image = self.snapshotImgOfCell(view)
            cellSnapshot = UIImageView(image: image)
        }
        
        return cellSnapshot
    }
    
    private func snapshotImgOfCell(_ view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return image
    }
    
    // MARK: UIViewController Preview Delegate (Peek) & related methods
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = self.tableView.indexPathForRow(at: location) {
            
            // previews the cell
            previewingContext.sourceRect = self.tableView.rectForRow(at: indexPath)
            guard let detailWeatherVc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "CityWeatherDetailViewController") as? CityWeatherDetailViewController else {
                return nil
            }
            
            // set frame of cell
            let rect = tableView.rectForRow(at: indexPath)
            let frameToOpenFrom = tableView.convert(rect, to: self.view)
            self.openingFrame = frameToOpenFrom
            
            // set selected city
            self.selectedCity = self.citiList?[indexPath.row]
            detailWeatherVc.currentCity = self.citiList?[indexPath.row]

            return detailWeatherVc
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        
        performSegue(withIdentifier: "showCityDetail", sender: nil)
    }
    
    private func viewControllerForIndexPath(indexPath: IndexPath) {
        
    }
    
    
    // MARK: tableview Delegates
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.citiList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cityWeatherCell", for: indexPath) as? CityWeatherCell
        
        if cell == nil {
            cell = CityWeatherCell(style: .default, reuseIdentifier: "cityWeatherCell")
        }
        
        if let city = citiList?[indexPath.row]{
            cell?.layoutIfNeeded()
            
            if city.needsUpdate {
                
                WeatherAPI.queryWeatherWithCityId(city.id, units: "metric", completion: { (jsonData, error) in
                    if let err = error {
                        print("error.. \(err)")
                    } else {
                        if let json = jsonData {
                            
                            let cityJson = JSON(json)
                            let city = City(id: "\(cityJson["id"].intValue)", name: cityJson["name"].stringValue, latitude: cityJson["coord"]["lat"].doubleValue, longitude: cityJson["coord"]["lon"].doubleValue, countryCode: cityJson["sys"]["country"].stringValue)
                            
                            city.timezone = TimeZoneLocate.timeZoneWithLocation(CLLocation(latitude: city.latitude, longitude: city.longitude))
                            
                            city.needsUpdate = false
                            
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
                            weather.visibility = cityJson["visibility"].intValue
                            weather.sunrize =  Date(timeIntervalSince1970: TimeInterval(cityJson["sys"]["sunrise"].intValue))
                            weather.sunset =  Date(timeIntervalSince1970: TimeInterval(cityJson["sys"]["sunset"].intValue))
                            city.weather = weather
                            
                            for (index, thisCity) in (self.citiList?.enumerated())! {
                                if thisCity.id == city.id {
                                    self.citiList?[index] = city
                                }
                            }
                            
                            print("City: \(city.name) has been updated.")
                            
                            if let cellToUpdate = self.tableView?.cellForRow(at: indexPath) as? CityWeatherCell{
                                cellToUpdate.updateCell(city)
                                cellToUpdate.setNeedsLayout()
                            }
                            
                            self.refresh.endRefreshing()
                            
//                            // temprary turn off lastUpdatedDate
//                            let date = Date()
//                            self.refresh.updateLastUpdatedDate(date(: date)
//                            UserDefaults.standard.set(date, forKey: "lastUpdatedDate")
//                            UserDefaults.standard.synchronize()
                        }
                    }
                })
            }
 
            cell?.updateCell(city)
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let theCell = cell as? CityWeatherCell {
            theCell.animateEffects()
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let theCell = cell as? CityWeatherCell {
            theCell.stopAnimatingEffects()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCity = self.citiList?[indexPath.row]
        
        // set frame of cell
        let rect = tableView.rectForRow(at: indexPath)
        let frameToOpenFrom = tableView.convert(rect, to: self.view)
        self.openingFrame = frameToOpenFrom
        
        
        performSegue(withIdentifier: "showCityDetail", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let city = self.citiList?[indexPath.row]
            citiList?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            tableView.endUpdates()
            
            // add city to user defaults
            UserDefaultManager.addCityToUserDefault(self.citiList!, withKey: "cityList")
            print("The city \(city!.name) is deleted.")
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CityWeatherCell
        cell.backgroundWeatherView.clipsToBounds = true
    }
    
    // MARK: Page Modal Animations
    func maximizeView(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: nil)
        
    }
    
    func minimizeView(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.935, y: 0.935)
        }, completion: nil)
    }
    
    // MARK: Page transition hooks
    
    func openAddCityVc() {
        self.performSegue(withIdentifier: "addCityViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "showCityDetail" {
            let weatherDetailVc = segue.destination as! CityWeatherDetailViewController
            if let city = self.selectedCity {
                weatherDetailVc.currentCity = city
            }
        } else if let id = segue.identifier, id == "showSettings" {
            let settingsVc = segue.destination as! SettingsViewController
            settingsVc.transitioningDelegate = self
            settingsVc.interactor = panGestureInteractor
        } else if let id = segue.identifier, id == "showViewController" {
            let settingsVc = segue.destination as! ViewController
            settingsVc.transitioningDelegate = self
            settingsVc.interactor = panGestureInteractor
        } else if let id = segue.identifier, id == "addCityViewConroller" {
        }
    }
    
    @IBAction func unwindFromSettingViewConroller(segue: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
    
}

// MARK: UIViewControllerTransitioningDelegate methods
extension WeatherListViewController: UIViewControllerTransitioningDelegate {
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        modalDismissAnimator.isPresenting = false
        return modalDismissAnimator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        modalDismissAnimator.isPresenting = true
        return modalDismissAnimator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.panGestureInteractor.hasStarted ? self.panGestureInteractor : nil
    }
}

extension WeatherListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        navTransitionAnimator.openingFrame = openingFrame!
        navTransitionAnimator.reverse = operation == .pop
        
        return navTransitionAnimator
    }
}

