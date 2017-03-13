//
//  RainEffectLayer.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-20.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class RainEffectLayer: WeatherEffectLayer {
    
    let kForgroundParticleBirthRate:Float = 50.0
    let kBackgroundParticleBirthRate:Float = 120.0
    
    let kForgroundParticleLifetime:Float = 2.0
    let kBackgroundParticleLifetime:Float = 4.0
    
    let kForgroundParticleVelocity:CGFloat = 600.0
    let kBackgroundParticleVelocity:CGFloat = 900.0
    
    let kForgroundParticleScale:CGFloat = 0.1
    let kBackgroundParticleScale:CGFloat = 0.07
    
    convenience init(frame: CGRect, dayNight: DayNight, displayType: LayerType) {
        self.init(frame: frame, dayNight: dayNight)
        layerType = displayType
        
        if self.layerType == LayerType.cell {
            switch dayNight {
            case .day:
                emitterLayer.backgroundColor = kColorBackgroundRainy.cgColor
                break
            case .night:
                emitterLayer.backgroundColor = kColorBackgroundRainyNight.cgColor
                break
            }
        }
        
        emitterLayer.emitterCells = [setUpEmitterCell(depthOfField: DepthOfField.foreground), setUpEmitterCell(depthOfField: DepthOfField.background)]
    }
    
    override init(frame: CGRect, dayNight: DayNight) {
        super.init(frame: frame, dayNight: dayNight)
    }
    
    func setUpEmitterCell(depthOfField: DepthOfField) -> CAEmitterCell{
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "particle_rain_new")?.cgImage
        
        switch depthOfField {
            case .foreground:
                emitterCell.lifetime = kForgroundParticleLifetime
                emitterCell.birthRate = kForgroundParticleBirthRate
                
                emitterCell.velocity = kForgroundParticleVelocity
                emitterCell.scale = kForgroundParticleScale
                break
            case .background:
                emitterCell.lifetime = kBackgroundParticleLifetime
                emitterCell.birthRate = kBackgroundParticleBirthRate
                
                emitterCell.velocity = kBackgroundParticleVelocity
                emitterCell.scale = kBackgroundParticleScale
                break
        }
        
        
        emitterCell.velocityRange = 200.0
        
        emitterCell.emissionLatitude = degreesToRadians(0)
        emitterCell.emissionLongitude = degreesToRadians(185)
        emitterCell.emissionRange = degreesToRadians(0)
        
        emitterCell.xAcceleration = -2
        emitterCell.yAcceleration = 10
        emitterCell.zAcceleration = 0
        
        emitterCell.alphaRange = 0.2
        
        emitterCell.color = UIColor.white.cgColor
        emitterCell.redRange = 0.0
        emitterCell.greenRange = 0.0
        emitterCell.blueRange = 0.0
        emitterCell.alphaRange = 0.0
        emitterCell.redSpeed = 0.0
        emitterCell.greenSpeed = 0.0
        emitterCell.blueSpeed = 0.0
        emitterCell.alphaSpeed = 0
        
        return emitterCell
    }
    
    override func setBackGroundGradientColors() {
        super.setBackGroundGradientColors()
        
        switch dayNight! {
        case .day:
            bgGradientLayer.colors = [kColorBackgroundRainy.cgColor, kColorBackgroundRainy2.cgColor]
            break
        case .night:
            bgGradientLayer.colors = [kColorBackgroundRainyNight.cgColor, kColorBackgroundRainyNight2.cgColor]
            break
        }
    }
    
    override func setCloudLayers() -> [CALayer]? {
        cloudLayer1 = CALayer()
        cloudLayer1?.contents = UIImage(named: "cloud_rain_2")?.cgImage
//        cloudLayer1?.backgroundColor = UIColor.red.cgColor
        cloudLayer1?.opacity = 0.3
        cloudLayer1?.frame = CGRect(x: 20, y: -80, width: 450, height: 330)
        
        let animation1 = CABasicAnimation(keyPath: "position.x")
        animation1.duration = 45
        animation1.byValue = 130
        animation1.repeatCount = 100
        animation1.autoreverses = true
        animation1.fillMode = kCAFillModeForwards
        animation1.isRemovedOnCompletion = false
        cloudLayer1?.add(animation1, forKey: "animation1")

        
        cloudLayer2 = CALayer()
        cloudLayer2?.contents = UIImage(named: "cloud_rain_2")?.cgImage
//        cloudLayer2?.backgroundColor = UIColor.orange.cgColor
        cloudLayer2?.opacity = 0.3
        cloudLayer2?.frame = CGRect(x: 180, y: -20, width: 350, height: 250)
        
        let animation2 = CABasicAnimation(keyPath: "position.x")
        animation2.duration = 50
        animation2.byValue = 90
        animation2.repeatCount = 100
        animation2.autoreverses = true
        animation2.fillMode = kCAFillModeForwards
        animation2.isRemovedOnCompletion = false
        cloudLayer2?.add(animation2, forKey: "animation2")
        
        
        cloudLayer3 = CALayer()
        cloudLayer3?.contents = UIImage(named: "cloud_rain_1")?.cgImage
//        cloudLayer3?.backgroundColor = UIColor.yellow.cgColor
        cloudLayer3?.opacity = 0.3
        cloudLayer3?.frame = CGRect(x: -100, y: -80, width: self.emitterLayer.frame.width, height: self.emitterLayer.frame.height / 2)
        
        let animation3 = CABasicAnimation(keyPath: "position.x")
        animation3.duration = 90
        animation3.byValue = 200
        animation3.repeatCount = 100
        animation3.autoreverses = true
        animation3.fillMode = kCAFillModeForwards
        animation3.isRemovedOnCompletion = false
        cloudLayer3?.add(animation3, forKey: "animation3")
        
        cloudLayer4 = CALayer()
        cloudLayer4?.contents = UIImage(named: "cloud_rain_2")?.cgImage
//        cloudLayer4?.backgroundColor = UIColor.green.cgColor
        cloudLayer4?.opacity = 0.3
        cloudLayer4?.frame = CGRect(x: 150, y: -40, width: 330, height: 240)
        
        cloudLayer5 = CALayer()
        cloudLayer5?.contents = UIImage(named: "cloud_rain_1")?.cgImage
//        cloudLayer5?.backgroundColor = UIColor.cyan.cgColor
        cloudLayer5?.opacity = 0.3
        cloudLayer5?.frame = CGRect(x: -120, y: -30, width: 450, height: 300)
        
        return [cloudLayer3!, cloudLayer1!, cloudLayer2! ]
    }
}
