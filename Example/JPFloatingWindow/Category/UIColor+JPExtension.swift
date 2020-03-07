//
//  UIColor+JPExtension.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/2/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    // CGFloat(arc4random_uniform(256))
    class func jp_randomColor(a: CGFloat = 1.0) -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)),
                       g: CGFloat(arc4random_uniform(256)),
                       b: CGFloat(arc4random_uniform(256)),
                       a: a)
    }
}

// MARK:- 从颜色中获取rgb的值
extension UIColor {
    /**
     * 从颜色中获取rgb的值
     * 为了确保拿到的是准确值而不是可选类型，先可选绑定（guard）判断该颜色是否通过rgb创建的颜色，不是直接跑出异常（让你崩溃！），确保这个颜色肯定有rgb值
     */
    func jp_getRGBValue() -> (CGFloat, CGFloat, CGFloat) {
        guard let components = cgColor.components else {
            fatalError("错误！请确定该颜色是通过rgb创建的！")
        }
        return (components[0] * 255, components[1] * 255, components[2] * 255)
    }
}
