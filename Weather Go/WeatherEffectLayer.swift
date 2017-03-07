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
    
    enum LayerType {
        case cell
        case full
    }
    
    enum DepthOfField {
        case foreground
        case background
    }
    
    enum DayNight {
        case day
        case night
    }
    
    let emitterLayer: CAEmitterLayer!
    let bgGradientLayer: CAGradientLayer!
    
    var dayNight: DayNight!
    var layerType: LayerType?
    
    convenience init(frame: CGRect, dayNight: DayNight, displayType: LayerType) {
        self.init(frame: frame, dayNight: dayNight)
        layerType = displayType
    }
    
    init(frame: CGRect, dayNight: DayNight) {
        emitterLayer = CAEmitterLayer()
        emitterLayer.frame = frame
        emitterLayer.seed = UInt32(NSDate().timeIntervalSince1970)
        emitterLayer.renderMode = kCAEmitterLayerAdditive
        emitterLayer.drawsAsynchronously = true
        
        self.dayNight = dayNight
        
        
        // keep emitter layer cell bg color for now
        if self.layerType == LayerType.cell {
            switch dayNight {
            case .day:
                emitterLayer.backgroundColor = kColorBackgroundDay.cgColor
                break
            case .night:
                emitterLayer.backgroundColor = kColorBackgroundNight.cgColor
                break
            }
        }
        
        bgGradientLayer = CAGradientLayer()
        bgGradientLayer.frame = frame
//        bgGradientLayer.startPoint = CGPoint(x: 0.3, y:0.0)
        
        setEmitterPosition()
        setBackGroundGradientColors()
    }
    
    func setEmitterPosition() {
        emitterLayer.emitterPosition = CGPoint(x: self.emitterLayer.bounds.midX, y: self.emitterLayer.bounds.minY - 50)
        emitterLayer.emitterSize = CGSize(width: self.emitterLayer.bounds.width * 1.2, height: 5)
        emitterLayer.emitterShape = kCAEmitterLayerLine;
    }
    
    func setBackGroundGradientColors() {
    }
    
    func degreesToRadians(_ degrees: Double) -> CGFloat {
        return CGFloat(degrees * M_PI / 180.0)
    }
    
}
