//
//  ModalDismissAnimator.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-02-03.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class ModalDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        if isPresenting {
            let viewBounds = containerView.bounds
            let originPoint = CGPoint(x: -viewBounds.width, y: 0)
            let fromRectFrame = CGRect(origin: originPoint, size: viewBounds.size)
            toVc.view.frame = fromRectFrame
            containerView.addSubview(toVc.view)
            
            let toRectFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: viewBounds.size)
            
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveLinear, animations: {
                fromVc.view.transform = CGAffineTransform(scaleX: 0.935, y: 0.935)
                toVc.view.frame = toRectFrame
            }, completion: { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
            
        } else {
            containerView.addSubview(fromVc.view)
            let viewBounds = containerView.bounds
            let originPoint = CGPoint(x: -viewBounds.width, y: 0)
            let toRectFrame = CGRect(origin: originPoint, size: viewBounds.size)
            
            let duration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveLinear, animations: {
                toVc.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                fromVc.view.frame = toRectFrame
            }, completion: { (completed) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        
        
    }
}
