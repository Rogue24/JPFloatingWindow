//
//  UIScrollView+JPExtension.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/2/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

extension UIScrollView {
    func jp_contentInsetAdjustmentNever() {
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
            guard let tableView = self as? UITableView else {
                return
            }
            tableView.estimatedRowHeight = 0
            tableView.estimatedSectionHeaderHeight = 0
            tableView.estimatedSectionFooterHeight = 0
        } else {
            // Fallback on earlier versions
        }
    }
}

