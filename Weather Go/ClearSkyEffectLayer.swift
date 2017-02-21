//
//  ClearSkyEffectLayer.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-20.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class ClearSkyEffectLayer: WeatherEffectLayer {
    
    override init(frame: CGRect, dayNight: DayNight) {
        super.init(frame: frame, dayNight: dayNight)
        
        switch dayNight {
        case .day:
            emitterLayer.backgroundColor = kColorBackgroundDay.cgColor
        case .night:
            emitterLayer.backgroundColor = kColorBackgroundNight.cgColor
        }
    }
    
}

