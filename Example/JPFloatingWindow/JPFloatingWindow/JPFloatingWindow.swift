//
//  JPFloatingWindow.swift
//  JPFloatingWindow
//
//  Created by 周健平 on 2020/3/2.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import AudioToolbox

class JPFloatingWindow: UIView {

    static let size : CGSize = CGSize(width: 64.0, height: 64.0) // 圆角 12
    
    var floatingVC : JPFloatingWindowProtocol
    let fwIcon : UIImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: JPFloatingWindow.size))
    
    var snapshotView : UIView?
    let snapshotMaskView : UIView
    let boomIcon : UIImageView
    
    var floatingPoint : CGPoint = CGPoint.zero
    
    init(frame: CGRect, floatingVC: JPFloatingWindowProtocol) {
        self.floatingVC = floatingVC
        
        boomIcon = UIImageView(image: UIImage(named: "icon_bomb"))
        boomIcon.frame = CGRect(origin: CGPoint.zero, size: JPFloatingWindow.size)
        boomIcon.isHidden = true
        
        snapshotMaskView = UIView(frame: floatingVC.view.bounds)
        snapshotMaskView.backgroundColor = UIColor.black
        snapshotMaskView.layer.masksToBounds = true
        
        fwIcon.image = UIImage(named: "jp_web_icon")
        fwIcon.layer.cornerRadius = 16
        fwIcon.layer.masksToBounds = true
        fwIcon.isHidden = true
        
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        // 为什么要截图？因为系统会控制poping控制器的view，会在某个时刻将其隐藏掉，我们这里得保留当前画面用作浮窗动画
        snapshotView = floatingVC.view.snapshotView(afterScreenUpdates: false)
        if let snapshotView = self.snapshotView {
            addSubview(snapshotView)
        }
        
        addSubview(boomIcon)
        addSubview(fwIcon)
        mask = snapshotMaskView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 区域修正，不超出屏幕
    fileprivate func checkFloatingPoint(_ floatingPoint: CGPoint) {
        
        let halfFwWH = JPFloatingWindow.size.width * 0.5
        let minX : CGFloat = halfFwWH
        let maxX : CGFloat = jp_portraitScreenWidth_ - halfFwWH
        let minY : CGFloat = jp_navTopMargin_ + halfFwWH
        let maxY : CGFloat = jp_portraitScreenHeight_ - jp_diffTabBarH_ - halfFwWH
        
        var point = floatingPoint
        if point.x < minX {
            point.x = minX
        } else if point.x > maxX {
            point.x = maxX
        }
        if point.y < minY {
            point.y = minY
        } else if point.y > maxY {
            point.y = maxY
        }
        
        self.floatingPoint = point
    }
}

extension JPFloatingWindow {
    
    // 浮窗生成动画
    func shrinkFloatingWindowAnimation(floatingPoint: CGPoint, completion: ((_ floatingWindow: JPFloatingWindow) -> Void)? = nil) {
        
        checkFloatingPoint(floatingPoint)
        
        AudioServicesPlaySystemSound(1397)
        
//        let radius : CGFloat = (fwIcon.layer.cornerRadius / fwIcon.bounds.width) * frame.size.width
        let radius : CGFloat = frame.width * 0.5
        let maskFrame = CGRect(x: 0,
                               y: (frame.height - frame.width) * 0.5,
                               width: frame.width,
                               height: frame.width)
//        let scale = fwIcon.bounds.width / frame.size.width
        let scale : CGFloat = 0.01
        
        if let snapshotView = self.snapshotView {
            UIView.animate(withDuration: 0.15) {
                snapshotView.alpha = 0
            }
        }
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            self.snapshotMaskView.layer.frame = maskFrame
            self.snapshotMaskView.layer.cornerRadius = radius
            self.snapshotMaskView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.center = self.floatingPoint
        }) { (finished) in
//            self.frame = self.fwIcon.frame
            self.frame = self.boomIcon.frame
            self.center = self.floatingPoint
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01).concatenating(CGAffineTransform.identity)
            
            self.mask = nil
            self.backgroundColor = UIColor.clear
//            self.fwIcon.isHidden = false
            self.boomIcon.isHidden = false

            AudioServicesPlaySystemSound(1396)

            UIView.animate(withDuration: 0.15, animations: {
                self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { (finished) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                }) { (finished) in
                    completion?(self)
                }
            }
        }
    }
    
    // 浮窗展开动画
    func spreadFloatingWindowAnimation(completion: ((_ floatingWindow: JPFloatingWindow) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            self.snapshotMaskView.layer.frame = jp_portraitScreenBounds_
            self.snapshotMaskView.layer.cornerRadius = 34
            self.floatingVC.view.alpha = 1
            self.fwIcon.alpha = 0
        }) { (finished) in
            completion?(self)
        }
    }
}
