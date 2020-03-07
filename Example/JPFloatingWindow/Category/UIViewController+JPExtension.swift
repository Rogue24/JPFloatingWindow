//
//  UIViewController+JPExtension.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/2/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIViewController {
    func jp_contentInsetAdjustmentNever(_ scrollView: UIScrollView? = nil) {
        automaticallyAdjustsScrollViewInsets = false
        guard let scrollView = scrollView else {
            return
        }
        scrollView.jp_contentInsetAdjustmentNever()
    }
}
