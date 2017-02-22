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
    
    let kForgroundParticleVelocity:CGFloat = 900.0
    let kBackgroundParticleVelocity:CGFloat = 1200.0
    
    let kForgroundParticleScale:CGFloat = 0.2
    let kBackgroundParticleScale:CGFloat = 0.15
    
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
        emitterCell.contents = UIImage(named: "particle_rain2")?.cgImage
        
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
        
        
        emitterCell.velocityRange = 100.0
        
        emitterCell.emissionLatitude = degreesToRadians(271)
        emitterCell.emissionLongitude = degreesToRadians(300)
        emitterCell.emissionRange = degreesToRadians(0)
        
        emitterCell.xAcceleration = -50
        emitterCell.yAcceleration = 1000
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
}
