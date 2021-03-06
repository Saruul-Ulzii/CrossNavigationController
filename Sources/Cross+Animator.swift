//
//  CrossTransitionAnimator.swift
//  CrossNavigationController
//
//  Created by yoshida hiroyuki on 2016/11/04.
//  Copyright © 2016年 hryk224. All rights reserved.
//

import UIKit
import Foundation

extension Cross {
    final class Animator: NSObject {
        public typealias Coordinate = Cross.Coordinate
        var operation: UINavigationControllerOperation = .none        
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension Cross.Animator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch operation {
        case .push, .pop:
            animation(using: transitionContext)
        case .none:
            return
        }
    }
}

// MARK: - Move
private extension Cross.Animator {
    func animation(using transitionContext: UIViewControllerContextTransitioning) {
        let cancelled = transitionContext.transitionWasCancelled
        guard let fromVC = transitionContext.viewController(forKey: .from) as? CrossViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? CrossViewController,
            let fromView = fromVC.view,
            let toView = toVC.view else {
                transitionContext.completeTransition(!cancelled)
                return
        }
        let containerView = transitionContext.containerView
        containerView.backgroundColor = fromView.backgroundColor ?? toView.backgroundColor ?? .clear
        fromView.frame = containerView.bounds
        toView.frame = containerView.bounds
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        let coordinate: Cross.Coordinate = fromVC.differenceCoordinate(toVC: toVC)
        let diff: (x: CGFloat, y: CGFloat) = (CGFloat(coordinate.x), CGFloat(coordinate.y))
        typealias Transfrom3d = (tx: CGFloat, ty: CGFloat, tz: CGFloat)
        let toViewTransfrom3d: Transfrom3d = (containerView.frame.width * diff.x, -containerView.frame.height * diff.y, 0)
        let fromViewTransfrom3d: Transfrom3d = (-containerView.frame.width * diff.x, containerView.frame.height * diff.y, 0)
        toView.layer.transform = CATransform3DMakeTranslation(toViewTransfrom3d.tx, toViewTransfrom3d.ty, toViewTransfrom3d.tz)
        fromView.layer.transform = CATransform3DIdentity
        let animations = {
            toView.layer.transform = CATransform3DIdentity
            fromView.layer.transform = CATransform3DMakeTranslation(fromViewTransfrom3d.tx, fromViewTransfrom3d.ty, fromViewTransfrom3d.tz)
        }
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear, animations: animations) { [weak self] finished in
            guard finished else { return }
            self?.animationCompletion(using: transitionContext, toView: toView, fromView: fromView)
        }
    }
    func animationCompletion(using transitionContext: UIViewControllerContextTransitioning, toView: UIView, fromView: UIView) {
        let cancelled = transitionContext.transitionWasCancelled
        if cancelled {
            toView.removeFromSuperview()
        } else {
            fromView.removeFromSuperview()
        }
        toView.layer.transform = CATransform3DIdentity
        fromView.layer.transform = CATransform3DIdentity
        transitionContext.completeTransition(!cancelled)
    }
}
