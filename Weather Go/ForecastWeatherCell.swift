//
//  ForecastWeatherCell.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-07.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class ForecastWeatherCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var precipImageView: UIImageView!
    @IBOutlet weak var precipLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
