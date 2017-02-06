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
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(fromVc.view)
        let viewBounds = containerView.bounds
        let bottomLeftPoint = CGPoint(x: 0, y: viewBounds.height)
        let belowRectFrame = CGRect(origin: bottomLeftPoint, size: viewBounds.size)
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: { 
            fromVc.view.frame = belowRectFrame
            
        }) { (completed) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
