//
//  JPFloatingWindowHook.swift
//  JPFloatingWindow
//
//  Created by 周健平 on 2020/3/1.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

protocol JPHookProtocol: NSObject {
    static var onceHook: Void { get }
}
extension JPHookProtocol {
    fileprivate static func swizzlingInstanceMethods(_ originalSelector: Selector, _ swizzledSelector: Selector) {
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIPercentDrivenInteractiveTransition: JPHookProtocol {
    internal static let onceHook: Void = {
        swizzlingInstanceMethods(#selector(cancel), #selector(jp_cancel))
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

extension UINavigationController: JPHookProtocol {
    internal static let onceHook: Void = {
        swizzlingInstanceMethods(
            #selector(pushViewController(_:animated:)),
            #selector(jp_pushViewController(_:animated:))
        )
        
        swizzlingInstanceMethods(
            #selector(popViewController(animated:)),
            #selector(jp_popViewController(animated:))
        )
        
        swizzlingInstanceMethods(
            Selector(("_updateInteractiveTransition:")),
            #selector(jp_updateInteractiveTransition(percent:))
        )
        
        swizzlingInstanceMethods(
            Selector(("_finishInteractiveTransition:transitionContext:")),
            #selector(jp_finishInteractiveTransition(percent:transitionContext:))
        )
        
        swizzlingInstanceMethods(
            Selector(("_cancelInteractiveTransition:transitionContext:")),
            #selector(jp_cancelInteractiveTransition(percent:transitionContext:))
        )
        
        swizzlingInstanceMethods(
            Selector(("didShowViewController:animated:")),
            #selector(jp_didShowViewController(_:animated:))
        )
    }()
    
    // pushViewController
    @objc fileprivate func jp_pushViewController(_ viewController: UIViewController, animated: Bool) {
        // 判断有没遵守协议，并且允不允许浮窗
        if let pushVC = viewController as? JPFloatingWindowProtocol {
            let animator = JPFwAnimator
            animator.isPush = true
            animator.navCtr = self
            animator.toVC = pushVC
            
            if let fromVC = self.topViewController {
                animator.fromVC = fromVC
                pushVC.jp_navigationController(self, animationWillBeginFor: true, from: fromVC, to: pushVC)
            }
            
            guard pushVC.jp_isFloatingEnabled == true else {
                jp_pushViewController(viewController, animated: animated)
                return
            }
            
            if animator.spreadFw == nil {
                animator.shrinkFwVC = pushVC
            } else {
                // 成为代理，自定义pop动画，为了让底下那层view固定住，不要有动画
                self.delegate = animator
            }
        }
        
        jp_pushViewController(viewController, animated: animated)
    }
    
    // popViewController
    @objc fileprivate func jp_popViewController(animated: Bool) -> UIViewController? {
        if let popVC = self.topViewController as? JPFloatingWindowProtocol {
            let animator = JPFwAnimator
            animator.isPush = false
            animator.navCtr = self
            animator.fromVC = popVC
            
            if self.viewControllers.count > 1, let popVcIndex = self.viewControllers.firstIndex(of: popVC) {
                let toVC : UIViewController = self.viewControllers[(popVcIndex - 1)]
                animator.toVC = toVC
                popVC.jp_navigationController(self, animationWillBeginFor: false, from: popVC, to: toVC)
            }
            
            guard popVC.jp_isFloatingEnabled == true else {
                return jp_popViewController(animated: animated)
            }
            
            animator.shrinkFwVC = popVC
            
            // 如果pop手势状态是begin，说明是手势返回
            // 系统的pop手势返回【不会触发代理方法】，所以没必要成为代理了
            if interactivePopGestureRecognizer?.state == .began {
                // 把判定半圆加上去
                view.addSubview(animator.decideView)
            } else {
                // 否则就是 自己触发/点击返回的，这种情况可以触发代理方法
                // 成为代理，自定义pop动画，为了让底下那层view固定住，不要有动画
                self.delegate = animator
            }
        }
        
        return jp_popViewController(animated: animated)
    }
    
    // 手势控制的过程，percent：动画进度
    @objc fileprivate func jp_updateInteractiveTransition(percent: CGFloat) {
        jp_updateInteractiveTransition(percent: percent)
        let animator = JPFwAnimator
        guard animator.shrinkFwVC != nil, animator.isPush == false else {
            return
        }
        animator.decideView.showPersent = percent * 2 // 滑到一半就显示完整
        animator.decideView.touchPoint = interactivePopGestureRecognizer!.location(in: view)
    }
    
    // 手势停止，确定完成动画，动画继续直到结束后的状态
    @objc fileprivate func jp_finishInteractiveTransition(percent: CGFloat, transitionContext: UIViewControllerContextTransitioning) {
        jp_finishInteractiveTransition(percent: percent, transitionContext: transitionContext)
        let animator = JPFwAnimator
        guard animator.shrinkFwVC != nil, animator.isPush == false else {
            return
        }
        if animator.decideView.isTouching {
            animator.jp_startShrinkFloatingWindowAnimation(percent: percent)
        }
        animator.decideView.decideDoneAnimation()
    }
    
    // 手势停止，确定取消动画，动画往返回到开始前的状态
    @objc fileprivate func jp_cancelInteractiveTransition(percent: CGFloat, transitionContext: UIViewControllerContextTransitioning) {
        jp_cancelInteractiveTransition(percent: percent, transitionContext: transitionContext)
        let animator = JPFwAnimator
        guard animator.shrinkFwVC != nil, animator.isPush == false else {
            return
        }
        // 隐藏判定半圆
        animator.decideView.decideDoneAnimation()
        // 系统的pop手势返回取消不会走didShowViewController方法，得手动调用转场结束方法
        animator.jp_navigationAnimationDone(isFinish: false)
    }
    
    // 转场完成后会走这个方法，转场取消（如cancelInteractiveTransition）则不会
    @objc func jp_didShowViewController(_ viewController: UIViewController, animated: Bool) {
        jp_didShowViewController(viewController, animated: animated)
        if let toVC = JPFwAnimator.toVC {
            JPFwAnimator.jp_navigationAnimationDone(isFinish: toVC == viewController)
        }
    }
}
