//
//  JPFloatingWindowAnimator.swift
//  JPFloatingWindow
//
//  Created by 周健平 on 2020/3/3.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class JPFloatingWindowAnimator: NSObject {
    var isPush : Bool = true
    
    var navCtr : UINavigationController?
    var fromVC : UIViewController?
    var toVC : UIViewController?
    
    var spreadFw : JPFloatingWindow?
    
    var shrinkFwVC : JPFloatingWindowProtocol?
    
    fileprivate(set) lazy var decideView : JPFloatingDecideView = {
        let decideView = JPFloatingDecideView()
        decideView.layer.zPosition = 10
        return decideView
    }()
}

// MARK: - <UINavigationControllerDelegate>
extension JPFloatingWindowAnimator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

// MARK: - <UIViewControllerAnimatedTransitioning>
extension JPFloatingWindowAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isPush == true ? 0.5 : 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPush == true {
            guard let fromVC = self.fromVC else {
                transitionContext.completeTransition(false)
                return
            }
            transitionContext.containerView.addSubview(fromVC.view)
            jp_startSpreadFloatingWindowAnimation(transitionContext)
        } else {
            guard let toVC = self.toVC else {
                transitionContext.completeTransition(false)
                return
            }
            transitionContext.containerView.addSubview(toVC.view)
            jp_startShrinkFloatingWindowAnimation(percent: 0, transitionContext)
        }
    }
}

// MARK: - push&pop结束处理
extension JPFloatingWindowAnimator {
    private func clearReferences() {
        navCtr = nil
        fromVC = nil
        toVC = nil
        shrinkFwVC = nil
        spreadFw = nil
    }
    
    func jp_navigationAnimationDone(isFinish: Bool) {
        guard let navCtr = self.navCtr else {
            clearReferences()
            return
        }
        
        if let navCtrDelegate = navCtr.delegate, navCtrDelegate.isEqual(self) {
            navCtr.delegate = nil
        }
        
        if let spreadFw = self.spreadFw {
            if let index = JPFwManager.floatingWindows.firstIndex(of: spreadFw) {
                JPFwManager.floatingWindows.remove(at: index)
                JPFwManager.floatingWindowsHasDidChanged?(false, index)
            }
        }
        
        if let fromVC = fromVC, let toVC = toVC {
            let targetVC : JPFloatingWindowProtocol = isPush == true ? (toVC as! JPFloatingWindowProtocol) : (fromVC as! JPFloatingWindowProtocol)
            if isFinish == true {
                targetVC.jp_navigationController(navCtr, animationEndedFor: isPush, from: fromVC, to: toVC)
            } else {
                targetVC.jp_navigationController(navCtr, animationCanceledFor: isPush, from: fromVC, to: toVC)
            }
        }
        
        clearReferences()
    }
}

// MARK: - 浮窗动画
extension JPFloatingWindowAnimator {
    func jp_startShrinkFloatingWindowAnimation(percent: CGFloat, _ transitionContext: UIViewControllerContextTransitioning? = nil) {
        // 可选校验
        guard let shrinkFwVC = shrinkFwVC else {
            return
        }
        
        // 获取poping控制器并对其view截个图（动画开始前要先把poping控制器的view隐藏）
        guard let fwView = shrinkFwVC.view else {
            return
        }
        
        guard let navCtr = navCtr else {
            return
        }
        
//        let transitionViewClass : AnyClass = NSClassFromString("UINavigationTransitionView")!
//        let wrapperViewClass : AnyClass = NSClassFromString("UIViewControllerWrapperView")!
//
//        // 获取pop动画过程的容器view
//        var wrapperView : UIView?
//        for subview in navCtr.view.subviews {
//            if subview.isKind(of: transitionViewClass) {
//                for subsubview in subview.subviews {
//                    if subsubview.isKind(of: wrapperViewClass) {
//                        wrapperView = subsubview
//                        break
//                    }
//                }
//                break
//            }
//        }
//        guard let containerView = wrapperView else {
//            return
//        }
//
//        // 获取poping控制器的view所在的父视图（用作位移动画的）
//        var wrapperSubView : UIView?
//        var beginView = fwView
//        while beginView.superview != nil {
//            let superview = beginView.superview!
//            if superview == containerView {
//                wrapperSubView = beginView
//                break
//            }
//            beginView = superview
//        }
//        guard let popSuperView = wrapperSubView else {
//            return
//        }
//
//        // 获取当前poping控制器的view的位置（presentationLayer，这个才是动画过程中准确看得到的layer）
//        guard let presentationLayer = popSuperView.layer.presentation() else {
//            return
//        }
//        let startFrame = presentationLayer.frame
        
        // 根据percent算出poping控制器的view的位置，创建浮窗对象
        let startFrame = CGRect(x: percent * shrinkFwVC.view.frame.width,
                                y: shrinkFwVC.view.frame.origin.y,
                                width: shrinkFwVC.view.frame.width,
                                height: shrinkFwVC.view.frame.height)
        let floatingWindow = JPFloatingWindow(frame: startFrame, floatingVC: shrinkFwVC)
        // 添加浮窗到当前容器视图内，盖住poping控制器的view
        navCtr.view.insertSubview(floatingWindow, belowSubview: navCtr.navigationBar)
        // 隐藏poping控制器的view
        fwView.isHidden = true
        
        // 搞个随机点
        let randomPoint = CGPoint(x: CGFloat(arc4random_uniform(UInt32(jp_portraitScreenWidth_))),
                                  y: CGFloat(arc4random_uniform(UInt32(jp_portraitScreenHeight_))))
//        let randomPoint = CGPoint(x: 100, y: 50)
        
        // 开始浮窗动画
        floatingWindow.shrinkFloatingWindowAnimation(floatingPoint: randomPoint) { (kFloatingWindow) in
            kFloatingWindow.removeFromSuperview()
            transitionContext?.completeTransition(true)
            
            JPFwManager.floatingWindows.insert(kFloatingWindow, at: 0)
            JPFwManager.floatingWindowsHasDidChanged?(true, 0)
        }
    }
    
    func jp_startSpreadFloatingWindowAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let spreadFw = spreadFw else {
            transitionContext.completeTransition(false)
            return
        }
        
        let containerView = transitionContext.containerView
        
        spreadFw.alpha = 1
        spreadFw.transform = CGAffineTransform.identity
        spreadFw.frame = jp_portraitScreenBounds_
        spreadFw.backgroundColor = UIColor.white
        
        spreadFw.floatingVC.view.isHidden = false
        spreadFw.floatingVC.view.frame = jp_portraitScreenBounds_
        spreadFw.floatingVC.view.alpha = 0
        spreadFw.addSubview(spreadFw.floatingVC.view)
        
        spreadFw.snapshotMaskView.transform = CGAffineTransform.identity
        spreadFw.snapshotMaskView.frame = CGRect(origin: CGPoint.zero, size: JPFloatingWindow.size)
        spreadFw.snapshotMaskView.layer.cornerRadius = 16
        spreadFw.snapshotMaskView.center = spreadFw.floatingPoint
        spreadFw.mask = spreadFw.snapshotMaskView
        
        spreadFw.fwIcon.isHidden = false
        spreadFw.fwIcon.center = spreadFw.floatingPoint
        
        spreadFw.boomIcon.isHidden = true
        
        containerView.addSubview(spreadFw)
        
        spreadFw.spreadFloatingWindowAnimation(completion: { (kFloatingWindow) in
            containerView.addSubview(kFloatingWindow.floatingVC.view)
            kFloatingWindow.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
}
