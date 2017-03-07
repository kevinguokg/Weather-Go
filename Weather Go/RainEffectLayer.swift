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
}
