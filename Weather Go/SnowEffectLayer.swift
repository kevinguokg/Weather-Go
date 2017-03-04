//
//  SnowEffectLayer.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-22.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class SnowEffectLayer: WeatherEffectLayer {
    
    let kForgroundParticleBirthRate:Float = 60.0
    let kBackgroundParticleBirthRate:Float = 100.0
    
    let kForgroundParticleLifetime:Float = 15.0
    let kBackgroundParticleLifetime:Float = 10.0
    
    let kForgroundParticleVelocity:CGFloat = 10.0
    let kBackgroundParticleVelocity:CGFloat = 5.0
    
    let kForgroundParticleScale:CGFloat = 0.09
    let kBackgroundParticleScale:CGFloat = 0.06
    
    override init(frame: CGRect, dayNight: DayNight) {
        super.init(frame: frame, dayNight: dayNight)
        
        switch dayNight {
        case .day:
            emitterLayer.backgroundColor = kColorBackgroundRainy.cgColor
            break
        case .night:
            emitterLayer.backgroundColor = kColorBackgroundRainyNight.cgColor
            break
        }
        
        emitterLayer.emitterCells = [setUpEmitterCell(depthOfField: DepthOfField.foreground), setUpEmitterCell(depthOfField: DepthOfField.background)]
    }
    
    func setUpEmitterCell(depthOfField: DepthOfField) -> CAEmitterCell{
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "spark")?.cgImage
        
        switch depthOfField {
        case .foreground:
            emitterCell.lifetime = kForgroundParticleLifetime
            emitterCell.birthRate = kForgroundParticleBirthRate
            
            emitterCell.velocity = kForgroundParticleVelocity
            emitterCell.scale = kForgroundParticleScale
            emitterCell.alphaSpeed = -1 / kForgroundParticleLifetime
            break
        case .background:
            
            emitterCell.lifetime = kBackgroundParticleLifetime
            emitterCell.birthRate = kBackgroundParticleBirthRate
            
            emitterCell.velocity = kBackgroundParticleVelocity
            emitterCell.scale = kBackgroundParticleScale
            emitterCell.alphaSpeed = -1 / kBackgroundParticleLifetime
            break
        }
        
        emitterCell.velocityRange = 300.0
        
        emitterCell.emissionLatitude = degreesToRadians(271)
        emitterCell.emissionLongitude = degreesToRadians(300)
        emitterCell.emissionRange = degreesToRadians(0)
        
        emitterCell.xAcceleration = -0.5
        emitterCell.yAcceleration = 9.8
        emitterCell.zAcceleration = 0
        
        emitterCell.alphaRange = 0.2
        emitterCell.color = UIColor.white.cgColor
        emitterCell.redRange = 0.0
        emitterCell.greenRange = 0.0
        emitterCell.blueRange = 0.0
        emitterCell.alphaRange = 0.5
        emitterCell.redSpeed = 0.0
        emitterCell.greenSpeed = 0.0
        emitterCell.blueSpeed = 0.0
        
        
        return emitterCell
    }
}
