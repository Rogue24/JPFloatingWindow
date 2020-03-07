//
//  JPFloatingWindowHook.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/3/1.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension NSObject {
    fileprivate static func jp_swizzlingForClass(originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        guard originalMethod != nil, swizzledMethod != nil else {
            return
        }
        method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
}

extension UIPercentDrivenInteractiveTransition {
    static func jp_takeOnceTimeFunc() {
        jp_takeOnceTime
    }
    private static let jp_takeOnceTime: Void = {
        jp_swizzlingForClass(originalSelector: #selector(cancel), swizzledSelector: #selector(jp_cancel))
    }()
    
    // 有时候已经滑到判定区域里面，但还是会取消pop，这是系统自身的判断（例如手指滑到了iPhoneX的下巴），这里hook来自己判断
    @objc fileprivate func jp_cancel() {
        guard JPFwAnimator.shrinkFwVC != nil, JPFwAnimator.isPush == false else {
            jp_cancel()
            return
        }
        if JPFwAnimator.decideView.isTouching == true {
            finish()
        } else {
            jp_cancel()
        }
    }
}

extension UINavigationController {
    static func jp_takeOnceTimeFunc() {
        jp_takeOnceTime
    }
    private static let jp_takeOnceTime: Void = {
        jp_swizzlingForClass(originalSelector: #selector(pushViewController(_:animated:)), swizzledSelector: #selector(jp_pushViewController(_:animated:)))
        jp_swizzlingForClass(originalSelector: #selector(popViewController(animated:)), swizzledSelector: #selector(jp_popViewController(animated:)))
        jp_swizzlingForClass(originalSelector: Selector(("_updateInteractiveTransition:")), swizzledSelector: #selector(jp_updateInteractiveTransition(percent:)))
        jp_swizzlingForClass(originalSelector: Selector(("_finishInteractiveTransition:transitionContext:")), swizzledSelector: #selector(jp_finishInteractiveTransition(percent:transitionContext:)))
        jp_swizzlingForClass(originalSelector: Selector(("_cancelInteractiveTransition:transitionContext:")), swizzledSelector: #selector(jp_cancelInteractiveTransition(percent:transitionContext:)))
    }()
    
    @objc fileprivate func jp_pushViewController(_ viewController: UIViewController, animated: Bool) {
        // 判断有没遵守协议，并且允不允许浮窗
        if let pushVC = viewController as? JPFloatingWindowProtocol, pushVC.jp_isFloatingEnabled == true {
            JPFwAnimator.isPush = true
            
            if JPFwAnimator.spreadFw == nil {
                JPFwAnimator.shrinkFwVC = pushVC
            }
            
            self.delegate = JPFwAnimator
        }
        jp_pushViewController(viewController, animated: animated)
    }
    
    @objc fileprivate func jp_popViewController(animated: Bool) -> UIViewController? {
        // 判断有没遵守协议，并且允不允许浮窗
        if let popVC = self.topViewController as? JPFloatingWindowProtocol, popVC.jp_isFloatingEnabled == true {
            JPFwAnimator.isPush = false
            
            JPFwAnimator.shrinkFwVC = popVC
            
            // 如果pop手势状态是begin，说明是手势返回，系统的pop手势返回不会触发代理方法，那就没必要成为代理了，手动执行
            if interactivePopGestureRecognizer?.state == .began {
                // 把判断view加上去
                view.addSubview(JPFwAnimator.decideView)
                
                JPFwAnimator.navCtr = self
                JPFwAnimator.fromVC = popVC
                if self.viewControllers.count > 1, let popVcIndex : Int = self.viewControllers.firstIndex(of: popVC) {
                    let toVC : UIViewController = self.viewControllers[(popVcIndex - 1)]
                    JPFwAnimator.toVC = toVC
                    popVC.jp_navigationController(self, animationWillBeginFor: false, from: popVC, to: toVC)
                }
            } else {
                // 否则就是 自己触发/点击返回的，这种情况可以触发代理方法
                // 这种情况就成为代理，自定义pop动画吧，不然导航栏瞬间变化会挺生硬的，只需要把toVC固定就OK，效果还阔以吧
                self.delegate = JPFwAnimator
            }
        }
        return jp_popViewController(animated: animated)
    }
    
    @objc fileprivate func jp_updateInteractiveTransition(percent: CGFloat) {
        jp_updateInteractiveTransition(percent: percent)
        
        let animator = JPFwAnimator
        guard animator.shrinkFwVC != nil, animator.isPush == false else {
            return
        }
        
        animator.decideView.showPersent = percent * 2 // 滑到一半就显示完整
        animator.decideView.touchPoint = interactivePopGestureRecognizer!.location(in: view)
    }
    
    @objc fileprivate func jp_finishInteractiveTransition(percent: CGFloat, transitionContext: UIViewControllerContextTransitioning) {
        jp_finishInteractiveTransition(percent: percent, transitionContext: transitionContext)
       
        let animator = JPFwAnimator
        guard animator.shrinkFwVC != nil, animator.isPush == false else {
            return
        }
        animator.jp_navigationAnimationDone(isFinish: true, isInteractive: true, percent)
    }
    
    @objc fileprivate func jp_cancelInteractiveTransition(percent: CGFloat, transitionContext: UIViewControllerContextTransitioning) {
        jp_cancelInteractiveTransition(percent: percent, transitionContext: transitionContext)
        
        let animator = JPFwAnimator
        guard animator.shrinkFwVC != nil, animator.isPush == false else {
            return
        }
        animator.jp_navigationAnimationDone(isFinish: false, isInteractive: true)
    }
}
