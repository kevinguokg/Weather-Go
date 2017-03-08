//
//  MenuView.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-03-07.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class MenuView: UIView {
    
    override func draw(_ rect: CGRect) {
        let barHeight = self.bounds.height/6
        
        var path = UIBezierPath(roundedRect: CGRect(x: 0 , y: self.bounds.height/4, width: self.bounds.width, height: self.bounds.height/6), cornerRadius: 1)
        
        path.lineWidth = 0.0
        kColorMenuBarGrey.setFill()
        UIColor.black.setStroke()
        path.fill()
        
        path = UIBezierPath(roundedRect: CGRect(x: 0 , y: self.bounds.height/4 + (barHeight + 2) * 1, width: self.bounds.width, height: barHeight), cornerRadius: 1)
        path.fill()
        
        path = UIBezierPath(roundedRect: CGRect(x: 0 , y: self.bounds.height/4 + (barHeight + 2) * 2, width: self.bounds.width, height: barHeight), cornerRadius: 1)
        path.fill()
        
        layer.masksToBounds = true
    }
}
