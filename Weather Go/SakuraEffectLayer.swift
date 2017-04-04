//
//  SakuraEffectLayer.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-04-03.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import  UIKit

class SakuraEffectLayer:WeatherEffectLayer {
    
    let kForgroundParticleBirthRate:Float = 12.0
    let kBackgroundParticleBirthRate:Float = 9.0
    
    let kForgroundParticleLifetime:Float = 18.0
    let kBackgroundParticleLifetime:Float = 15.0
    
    let kForgroundParticleVelocity:CGFloat = 10.0
    let kBackgroundParticleVelocity:CGFloat = 5.0
    
    let kForgroundParticleScale:CGFloat = 0.04
    let kBackgroundParticleScale:CGFloat = 0.02
    
    convenience init(frame: CGRect, dayNight: DayNight, displayType: LayerType) {
        self.init(frame: frame, dayNight: dayNight)
        layerType = displayType
        
        if layerType == LayerType.cell {
            switch dayNight {
            case .day:
                emitterLayer.backgroundColor = UIColor.clear.cgColor
                break
            case .night:
                emitterLayer.backgroundColor = UIColor.clear.cgColor
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
        emitterCell.contents = UIImage(named: "particle_sakura")?.cgImage
        
        switch depthOfField {
        case .foreground:
            emitterCell.lifetime = kForgroundParticleLifetime
            emitterCell.birthRate = kForgroundParticleBirthRate
            
            emitterCell.velocity = kForgroundParticleVelocity
            emitterCell.scale = kForgroundParticleScale
            emitterCell.alphaSpeed = -1 / (kForgroundParticleLifetime * 1.5)
            break
        case .background:
            
            emitterCell.lifetime = kBackgroundParticleLifetime
            emitterCell.birthRate = kBackgroundParticleBirthRate
            
            emitterCell.velocity = kBackgroundParticleVelocity
            emitterCell.scale = kBackgroundParticleScale
            emitterCell.alphaSpeed = -1 / (kBackgroundParticleLifetime * 1.5)
            break
        }
        
        emitterCell.velocityRange = 300.0
        
        emitterCell.emissionLatitude = degreesToRadians(271)
        emitterCell.emissionLongitude = degreesToRadians(269)
        emitterCell.emissionRange = degreesToRadians(20)
        
        emitterCell.xAcceleration = -0.5
        emitterCell.yAcceleration = 9.8
        emitterCell.zAcceleration = 0
        
        emitterCell.alphaRange = 0.2

        emitterCell.color = UIColor.white.cgColor
        emitterCell.redRange = 1.0
        emitterCell.greenRange = 0.0
        emitterCell.blueRange = 0.0
        emitterCell.redSpeed = 0.2
        emitterCell.greenSpeed = 0.0
        emitterCell.blueSpeed = 0.0
        
        emitterCell.spin = 1.0
        emitterCell.spinRange = 0.6
        
        emitterCell.scaleRange = 0.01
    
        
        return emitterCell
    }
    
}
