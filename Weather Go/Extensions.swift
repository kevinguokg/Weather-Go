//
//  Extensions.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-10.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let quickActionOpenAddCityVc = Notification.Name("quickActionOpenAddCityVc")
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alphaa: CGFloat) {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: alphaa)
    }
}

extension UIView {
    func snapshotOfView(bound: CGRect) -> UIView? {
        guard let image = self.snapshotImgOfView(bound: bound) else {
            return nil
        }
        
        let snapshotImgOfView: UIView = UIImageView(image:image)
        snapshotImgOfView.layer.masksToBounds = false
        snapshotImgOfView.layer.cornerRadius = 0.0
        
        return snapshotImgOfView
    }
    
    func snapshotImgOfView(bound: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 3.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        
        UIGraphicsBeginImageContextWithOptions(bound.size, false, 3.0)
        image.draw(at: CGPoint(x: -bound.origin.x, y: -bound.origin.y))
        
        let choppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //UIImageWriteToSavedPhotosAlbum(choppedImage!, nil, nil, nil)
        
        return choppedImage
    }
    

}
