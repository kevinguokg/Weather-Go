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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        UserDefaults.standard.set(indexPath.row == 1, forKey: "isMetric")
        
        self.dismiss(animated: true, completion: nil)
    }
}
