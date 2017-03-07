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
    
    let kForgroundParticleBirthRate:Float = 10.0
    let kBackgroundParticleBirthRate:Float = 20.0
    
    let kForgroundParticleLifetime:Float = 15.0
    let kBackgroundParticleLifetime:Float = 30.0
    
    let kForgroundParticleVelocity:CGFloat = 0.0
    let kBackgroundParticleVelocity:CGFloat = 0.0
    
    let kForgroundParticleScale:CGFloat = 0.035
    let kBackgroundParticleScale:CGFloat = 0.02
    
    var displayType: LayerType = LayerType.full
    
    var sunLightLayer: CAShapeLayer?
    
    convenience init(frame: CGRect, dayNight: DayNight, displayType: LayerType) {
        self.init(frame: frame, dayNight: dayNight)
        self.displayType = displayType
        
        
        switch dayNight {
        case .day:
            if displayType == LayerType.cell {
                 emitterLayer.backgroundColor = kColorBackgroundDay.cgColor
            }
            break
        case .night:
            if displayType == LayerType.cell {
                emitterLayer.backgroundColor = kColorBackgroundNight.cgColor
            }
            emitterLayer.emitterCells = [setUpEmitterCell(depthOfField: DepthOfField.foreground), setUpEmitterCell(depthOfField: DepthOfField.background), setUpShootingStarCell()]
            break
        }
    }
    
    override init(frame: CGRect, dayNight: DayNight) {
        super.init(frame: frame, dayNight: dayNight)
    }
    
    override func setEmitterPosition() {
        emitterLayer.emitterPosition = CGPoint(x: self.emitterLayer.bounds.midX, y: self.emitterLayer.bounds.minY)
        emitterLayer.emitterSize = CGSize(width: self.emitterLayer.bounds.width, height: self.emitterLayer.bounds.height * 2)
        emitterLayer.emitterShape = kCAEmitterLayerRectangle;
    }
    
    
    func setUpEmitterCell(depthOfField: DepthOfField) -> CAEmitterCell{
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "spark")?.cgImage
        
        switch depthOfField {
        case .foreground:
            emitterCell.lifetime = kForgroundParticleLifetime
            emitterCell.birthRate = self.displayType == LayerType.full ? kForgroundParticleBirthRate : kForgroundParticleBirthRate / 2
            
            emitterCell.velocity = kForgroundParticleVelocity
            emitterCell.scale = kForgroundParticleScale
            emitterCell.alphaSpeed = -1/kForgroundParticleLifetime
            break
        case .background:
            
            emitterCell.lifetime = kBackgroundParticleLifetime
            emitterCell.birthRate = self.displayType == LayerType.full ? kBackgroundParticleBirthRate : kBackgroundParticleBirthRate / 2
            
            emitterCell.velocity = kBackgroundParticleVelocity
            emitterCell.scale = kBackgroundParticleScale
            emitterCell.alphaSpeed = -1/kBackgroundParticleLifetime
            break
        }
        
        
        emitterCell.velocityRange = 0.0
        
        emitterCell.emissionLatitude = degreesToRadians(271)
        emitterCell.emissionLongitude = degreesToRadians(300)
        emitterCell.emissionRange = degreesToRadians(0)
        
        emitterCell.xAcceleration = 0
        emitterCell.yAcceleration = 0
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
        
        
        return emitterCell
    }

    
    func setUpShootingStarCell() -> CAEmitterCell {
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "shooting_star")?.cgImage
        emitterCell.lifetime = self.displayType == LayerType.full ? 120 : 200
        emitterCell.birthRate = 1
        emitterCell.velocity = 750
        emitterCell.scale = 0.6
        emitterCell.alphaSpeed = -1/emitterCell.lifetime
        
        emitterCell.velocityRange = 100.0
        
        emitterCell.emissionLatitude = degreesToRadians(180)
        emitterCell.emissionLongitude = degreesToRadians(300)
        emitterCell.emissionRange = degreesToRadians(0)
        
        emitterCell.xAcceleration = -100
        emitterCell.yAcceleration = 200
        emitterCell.zAcceleration = 0
        emitterCell.scaleRange = 0.1
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
    
    func createSunLightLayer() -> CAShapeLayer {
        let sunShadowLayer = CAShapeLayer()
        
//        sunShadowLayer?.fillColor = kColorSunLight.cgColor
//        sunShadowLayer?.lineWidth = 0.5
//        sunShadowLayer.shadow
        
        
        self.sunLightLayer = CAShapeLayer()
        switch displayType {
        case .cell:
            sunLightLayer?.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 100, height: 100)).cgPath
            sunLightLayer?.shadowPath = UIBezierPath(ovalIn: CGRect(x: -25, y: -25, width: 150, height: 150)).cgPath
            break
            
        case .full:
            sunLightLayer?.path = UIBezierPath(arcCenter: CGPoint(x: emitterLayer.bounds.midX,y: 180), radius: CGFloat(120), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true).cgPath
            
            sunLightLayer?.shadowPath = UIBezierPath(arcCenter: CGPoint(x: emitterLayer.bounds.midX,y: 180), radius: CGFloat(180), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true).cgPath
            
            break
            
        }
        sunLightLayer?.fillColor = kColorSunLight.cgColor
        sunLightLayer?.lineWidth = 0
        sunLightLayer?.shadowRadius = 5
        sunLightLayer?.shadowOpacity = 1
        //sunLightLayer?.shadowOffset = CGSize(width: 3, height: 3)
        sunLightLayer?.shadowColor = kColorSunLightOutside.cgColor
        
        
        let shineAnimation = CABasicAnimation(keyPath: "opacity")
        shineAnimation.fromValue = 0.4
        shineAnimation.toValue = 0.8
        shineAnimation.duration = 10
        shineAnimation.autoreverses = true
//        shineAnimation.isCumulative = true
        shineAnimation.repeatCount = 100
        shineAnimation.fillMode = kCAFillModeForwards
        shineAnimation.isRemovedOnCompletion = false
        
        sunLightLayer?.add(shineAnimation, forKey: "sunshineAnim")
        
        return sunLightLayer!
    }
    
    override func setBackGroundGradientColors() {
        super.setBackGroundGradientColors()
        
        switch dayNight! {
        case .day:
            bgGradientLayer.colors = [kColorBackgroundDay.cgColor, kColorBackgroundDay2.cgColor]
            break
        case .night:
            bgGradientLayer.colors = [kColorBackgroundNight2.cgColor, kColorBackgroundNight.cgColor]
            break
        }
    }
}

