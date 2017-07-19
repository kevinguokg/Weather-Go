//
//  NavigationTransitionAnimator.swift
//  Weather Go
//
//  Created by Kevin Guo on 2017-03-06.
//  Copyright © 2017 Kevin Guo. All rights reserved.
//

import Foundation
import UIKit

class NavigationTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var reverse: Bool = false
    var openingFrame: CGRect?
    
    var topView: UIView!
    var bottomView: UIView!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
 
    // fade
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let fromView = fromVc?.view
        let toView = toVc?.view
        
        if let fromView = fromView, let toView = toView {
            toView.alpha = 0
            
            containerView.addSubview(toView)
            containerView.addSubview(fromView)
            
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                fromView.alpha = 0
                toView.alpha = 1
                
            }, completion: { (success) in
                
                if (transitionContext.transitionWasCancelled) {
                    toView.removeFromSuperview()
                } else {
                    fromView.removeFromSuperview()
                }
                
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
        
    }
}
