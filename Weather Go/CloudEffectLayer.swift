//
//  CloudEffectLayer.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-20.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import  UIKit

class CloudEffectLayer: WeatherEffectLayer {
    
    override init(frame: CGRect, dayNight: DayNight) {
        super.init(frame: frame, dayNight: dayNight)
        
        switch dayNight {
        case .day:
            emitterLayer.backgroundColor = kColorBackgroundCloudDay.cgColor
            break
        case .night:
            emitterLayer.backgroundColor = kColorBackgroundCloudNight.cgColor
            break
        }
    }
}
