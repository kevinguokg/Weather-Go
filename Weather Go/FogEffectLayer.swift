//
//  FogEffectLayer.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-21.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class FogEffectLayer: WeatherEffectLayer {
    
    let kForgroundParticleBirthRate:Float = 150.0
    let kBackgroundParticleBirthRate:Float = 4.0
    
    let kForgroundParticleLifetime:Float = 10.0
    let kBackgroundParticleLifetime:Float = 4.0
    
    let kForgroundParticleVelocity:CGFloat = 5.0
    let kBackgroundParticleVelocity:CGFloat = -15.0
    
    let kForgroundParticleScale:CGFloat = 0.7
    let kBackgroundParticleScale:CGFloat = 0.15


    override init(frame: CGRect, dayNight: DayNight) {
        super.init(frame: frame, dayNight: dayNight)
        
        switch dayNight {
        case .day:
            emitterLayer.backgroundColor = kColorBackgroundCloudDay.cgColor
        case .night:
            emitterLayer.backgroundColor = kColorBackgroundCloudNight.cgColor
        }
        
        //self.setEmitterPosition()
        //emitterLayer.emitterCells = [setUpEmitterCell(depthOfField: DepthOfField.foreground)]

    }
    
//    override func setEmitterPosition() {
//        emitterLayer.emitterPosition = CGPoint(x: self.emitterLayer.bounds.midX, y: self.emitterLayer.bounds.minY)
//        emitterLayer.emitterSize = CGSize(width: self.emitterLayer.bounds.width, height: self.emitterLayer.bounds.height / 2)
//        emitterLayer.emitterShape = kCAEmitterLayerRectangle;
//    }
    
    func setUpEmitterCell(depthOfField: DepthOfField) -> CAEmitterCell {
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "spark")?.cgImage
        
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
        
        emitterCell.velocityRange = 2.0
        
        emitterCell.emissionLatitude = degreesToRadians(271)
        emitterCell.emissionLongitude = degreesToRadians(300)
        emitterCell.emissionRange = degreesToRadians(180)
        
        emitterCell.xAcceleration = 0
        emitterCell.yAcceleration = 25
        emitterCell.zAcceleration = 0
        
        emitterCell.spin = degreesToRadians(180)
        emitterCell.spinRange = degreesToRadians(30)
        
        emitterCell.color = kColorRainFropGreyFaint.cgColor
        emitterCell.redRange = 0.0
        emitterCell.greenRange = 0.0
        emitterCell.blueRange = 0.0
        emitterCell.redSpeed = 0.0
        emitterCell.greenSpeed = 0.0
        emitterCell.blueSpeed = 0.0
        emitterCell.alphaRange = 0.5
        emitterCell.alphaSpeed = -1.0/kForgroundParticleLifetime
        
        return emitterCell    }
}
