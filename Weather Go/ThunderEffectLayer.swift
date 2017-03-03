//
//  ThunderEffectLayer.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-27.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class ThunderEffectLayer: RainEffectLayer {
    
    func createBolt(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, displace: CGFloat, path: UIBezierPath) {
        if displace < 1.8 {
            let point = CGPoint(x: x2, y: y2)
            path.addLine(to: point)
        } else {
            var midX = (x2+x1)*0.5
            var midY = (y2+y1)*0.5
            midX += (CGFloat(arc4random_uniform(100)) * CGFloat(0.01) - CGFloat(0.5)) * displace
            midY += (CGFloat(arc4random_uniform(100)) * CGFloat(0.01) - CGFloat(0.5)) * displace
            
            createBolt(x1: x1, y1: y1, x2: midX, y2: midY, displace: displace * 0.5, path: path)
            createBolt(x1: midX, y1: midY, x2: x2, y2: y2, displace: displace * 0.5, path: path)
            
        }
    }

    func addBoltWith(startPoint: CGPoint, endPoint: CGPoint) -> CAShapeLayer {
        let numberOffset = 200
        let startX = CGFloat(arc4random_uniform(UInt32(numberOffset))) + (startPoint.x - 100)
        let startPoint = CGPoint(x: startX, y: startPoint.y)
        
        let endX = CGFloat(arc4random_uniform(UInt32(numberOffset))) + (endPoint.x - 100)
        let endPoint = CGPoint(x: endX, y: endPoint.y)
        
        // Dynamically calculating displace
        // Distance between two points
        let hypot = hypotf(fabsf(Float(endPoint.x) - Float(startPoint.x)), fabsf(Float(endPoint.y) - Float(startPoint.y)));
        // hypot/displace = 4/1
        let displace = hypot*0.40;
        
        let shapeLayer = CAShapeLayer()
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: startPoint)
        
        createBolt(x1: startPoint.x, y1: startPoint.y, x2: endPoint.x, y2: endPoint.y, displace: CGFloat(displace), path: bezierPath)
        shapeLayer.path = bezierPath.cgPath;
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 0.8;
        shapeLayer.fillColor = UIColor.clear.cgColor;
        shapeLayer.zPosition = 20;
        shapeLayer.shadowColor = UIColor.init(colorLiteralRed: 0.702, green: 0.745, blue: 1, alpha: 1.0).cgColor
        shapeLayer.shadowOffset = CGSize(width: 0, height: 0)
        shapeLayer.shadowRadius = 7.0
        shapeLayer.shadowOpacity = 1.0;
        shapeLayer.shouldRasterize = true;
        
        
        let expandAnim = CABasicAnimation(keyPath: "strokeEnd")
        expandAnim.fromValue = 0
        expandAnim.toValue = 1
        expandAnim.repeatCount = 1
        expandAnim.duration = 0.1
        expandAnim.fillMode = kCAFillModeForwards
        expandAnim.isRemovedOnCompletion = false
        shapeLayer.add(expandAnim, forKey: "expandAnim")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = 1
        fadeAnim.toValue = 0
        fadeAnim.repeatCount = 1
        fadeAnim.duration = 4
        fadeAnim.fillMode = kCAFillModeForwards
        fadeAnim.isRemovedOnCompletion = false
        shapeLayer.add(fadeAnim, forKey: "fadeAnim")
        
        return shapeLayer
    }
    
    func addLightning() -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.emitterLayer.frame.width, height: self.emitterLayer.frame.height), cornerRadius: 0).cgPath
        layer.fillColor = UIColor.white.cgColor
        
        let flashAnim = CABasicAnimation(keyPath: "opacity")
        flashAnim.fromValue = 1
        flashAnim.toValue = 0
        flashAnim.repeatCount = 3
        flashAnim.duration = 0.1
        flashAnim.fillMode = kCAFillModeForwards
        flashAnim.isRemovedOnCompletion = false
        
        layer.add(flashAnim, forKey: "flashAnim")
        
        return layer
    }
    
}
