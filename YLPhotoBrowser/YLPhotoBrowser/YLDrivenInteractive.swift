//
//  YLDrivenInteractive.swift
//  YLPhotoBrowser
//
//  Created by yl on 2017/7/25.
//  Copyright © 2017年 February12. All rights reserved.
//

import UIKit

class YLDrivenInteractive: UIPercentDrivenInteractiveTransition {
    
    var beforeImageViewFrame: CGRect = CGRect.zero
    var currentImageViewFrame: CGRect = CGRect.zero
    var currentImageView: UIImageView!
    
    var gestureRecognizer: UIPanGestureRecognizer! {
        didSet {
            gestureRecognizer.addTarget(self, action: #selector(YLDrivenInteractive.gestureRecognizeDidUpdate(_:)))
        }
    }
    
    private var transitionContext: UIViewControllerContextTransitioning!
    private var blackBgView: UIView?
    private var fromView: UIView?
    private var toView: UIView?
    
    private var isFirst = true
    
    func percentForGesture(_ gesture: UIPanGestureRecognizer) -> CGFloat {
        
        let translation = gesture.translation(in: gesture.view)
        var scale = 1 - fabs(translation.y / YLScreenH)
        scale = scale < 0 ? 0:scale
        
        return scale
    }
    
    func gestureRecognizeDidUpdate(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        let scrale = percentForGesture(gestureRecognizer)
        
        print("interactive \(scrale)")
        
        if isFirst {
            beginInterPercent()
            isFirst = false
        }
        
        switch gestureRecognizer.state {
        case .began:
            // 进不来
            break
        case .changed:
            update(percentForGesture(gestureRecognizer))
            updateInterPercent(percentForGesture(gestureRecognizer))
            break
        case .ended:
            
            if scrale > 0.9 {
                cancel()
                interPercentCancel()
            }else {
                finish()
                interPercentFinish(scrale)
            }
            
            break
        default:
            cancel()
            interPercentCancel()
            break
        }
        
    }
    
    func beginInterPercent() {
        
        let transitionContext = self.transitionContext
        
        // 转场过渡的容器view
        if let containerView = transitionContext?.containerView {
            
            // ToVC
            let toViewController = transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.to)
            toView = toViewController?.view
            containerView.addSubview(toView!)
            
            // 有渐变的黑色背景
            blackBgView = UIView.init(frame: containerView.bounds)
            blackBgView?.backgroundColor = UIColor.black
            containerView.addSubview(blackBgView!)
            
            // fromVC
            let fromViewController = transitionContext?.viewController(forKey: UITransitionContextViewControllerKey.from)
            fromView = fromViewController?.view
            containerView.addSubview(fromView!)
            
        }
    }
    
    func updateInterPercent(_ scale: CGFloat) {
        blackBgView?.alpha = scale * scale * scale
    }
    
    func interPercentCancel() {
        
        let transitionContext = self.transitionContext
        
        isFirst = true
        
        toView?.removeFromSuperview()
        blackBgView?.removeFromSuperview()
        
        transitionContext?.completeTransition(!(transitionContext?.transitionWasCancelled)!)
    }
    
    func interPercentFinish(_ scale: CGFloat) {
        
        let transitionContext = self.transitionContext
        
        // 转场过渡的容器view
        if let containerView = transitionContext?.containerView {
            
            // 过度的图片
            let transitionImgView = UIImageView.init(image: currentImageView.image)
            transitionImgView.clipsToBounds = true
            transitionImgView.frame = currentImageViewFrame
            containerView.addSubview(transitionImgView)
            
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveLinear, animations: { [weak self] in
                
                transitionImgView.frame = (self?.beforeImageViewFrame)!
                self?.blackBgView?.alpha = 0
                
            }) { [weak self] (finished: Bool) in
                
                self?.blackBgView?.removeFromSuperview()
                self?.fromView?.removeFromSuperview()
                transitionImgView.removeFromSuperview()
                
                transitionContext?.completeTransition(!(transitionContext?.transitionWasCancelled)!)
            }
        }
    }
    
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
    }
}
