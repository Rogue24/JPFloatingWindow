//
//  JPNavigationBackgroundView.swift
//  JPFloatingWindow
//
//  Created by 周健平 on 2020/3/5.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UINavigationBar {
    private static var JPNavBgViewKey = "\0"
    var jp_navBgView : UIView? {
        get {
            return objc_getAssociatedObject(self, &(UINavigationBar.JPNavBgViewKey)) as? UIView
        }
        set {
            if let oldNavBgView = jp_navBgView, let newNavBgView = newValue {
                if oldNavBgView == newNavBgView {
                    return
                } else {
                    oldNavBgView.removeFromSuperview()
                }
            }
            objc_setAssociatedObject(self, &(UINavigationBar.JPNavBgViewKey), newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func jp_setupCustomNavigationBgView(customBgView: UIView?) {
        if let backgroundView : UIView = value(forKey: "backgroundView") as? UIView {
            jp_navBgView = customBgView
            
            if let customBgView = customBgView {
                // 隐藏本来的导航栏背景和阴影线
                if shadowImage == nil || backgroundImage(for: .default) == nil {
                    setBackgroundImage(UIImage(), for: .default)
                    shadowImage = UIImage()
                }
                backgroundView.addSubview(customBgView)
            } else {
                setBackgroundImage(nil, for: .default)
                shadowImage = nil
            }
        }
    }

    func jp_setNavigationBgColor(color: UIColor) {
        if let navBgView = jp_navBgView {
            navBgView.backgroundColor = color
        }
    }

    func jp_setNavigationBgAlpha(alpha: CGFloat) {
        if let navBgView = jp_navBgView {
            navBgView.alpha = alpha
        }
    }
}
