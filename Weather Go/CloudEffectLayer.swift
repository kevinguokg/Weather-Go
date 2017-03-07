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
    
    convenience init(frame: CGRect, dayNight: DayNight, displayType: LayerType) {
        self.init(frame: frame, dayNight: dayNight)
        layerType = displayType
        
        if layerType == LayerType.cell {
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
        
    override init(frame: CGRect, dayNight: DayNight) {
        super.init(frame: frame, dayNight: dayNight)
        
    }
    
    override func setBackGroundGradientColors() {
        super.setBackGroundGradientColors()
        
        switch dayNight! {
        case .day:
            bgGradientLayer.colors = [kColorBackgroundCloudDay.cgColor, kColorBackgroundCloudDay2.cgColor]
            break
        case .night:
            bgGradientLayer.colors = [kColorBackgroundCloudNight.cgColor, kColorBackgroundCloudNight2.cgColor]
            break
        }
    }
}
