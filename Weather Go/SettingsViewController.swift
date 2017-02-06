//
//  SettingsViewController.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-01.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    var interactor:Interactor? = nil
    var isMetric:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let ges = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
//        self.view.addGestureRecognizer(ges)
        
        self.isMetric = UserDefaults.standard.bool(forKey: "isMetric")
    }
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let percentThreshold:CGFloat = 0.3
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translation(in: view)
        
        let verticalMovement = translation.y / view.bounds.height
        //print("verticalMovement= \(verticalMovement)")
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        //print("progress= \(progress)")
        
        guard let interactor = interactor else { return }
        
        switch sender.state {
            case .began:
                interactor.hasStarted = true
                dismiss(animated: true, completion: nil)
            case .changed:
                interactor.shouldFinish = progress > percentThreshold
                interactor.update(progress)
            case .cancelled:
                interactor.hasStarted = false
                interactor.cancel()
            case .ended:
                interactor.hasStarted = false
                interactor.shouldFinish ? interactor.finish() : interactor.cancel()
            default:
                break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(indexPath.row == 1, forKey: "isMetric")
        self.isMetric = UserDefaults.standard.bool(forKey: "isMetric")
        self.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.accessoryType = self.isMetric ? .none :.checkmark
                break
            case 1:
                cell.accessoryType = self.isMetric ? .checkmark :.none
                break
            default:
                break
            }
        default:
            break
        }
        
        return cell
        
    }
    
}
