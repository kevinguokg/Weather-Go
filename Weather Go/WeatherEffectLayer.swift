//
//  WeatherEffectLayer.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-20.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class WeatherEffectLayer {
    
    enum DepthOfField {
        case foreground
        case background
    }
    
    enum DayNight {
        case day
        case night
    }
    
    let emitterLayer: CAEmitterLayer!
    
    init(frame: CGRect, dayNight: DayNight) {
        emitterLayer = CAEmitterLayer()
        emitterLayer.frame = frame
        emitterLayer.seed = UInt32(NSDate().timeIntervalSince1970)
        emitterLayer.renderMode = kCAEmitterLayerAdditive
        emitterLayer.drawsAsynchronously = true
        
        switch dayNight {
            case .day:
                emitterLayer.backgroundColor = kColorBackgroundDay.cgColor
                break
            case .night:
                emitterLayer.backgroundColor = kColorBackgroundNight.cgColor
                break
        }
        setEmitterPosition()
    }
    
    func setEmitterPosition() {
        emitterLayer.emitterPosition = CGPoint(x: self.emitterLayer.bounds.midX, y: self.emitterLayer.bounds.minY - 50)
        emitterLayer.emitterSize = CGSize(width: self.emitterLayer.bounds.width * 1.2, height: 5)
        emitterLayer.emitterShape = kCAEmitterLayerLine;
    }
    
    func degreesToRadians(_ degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
    
}
