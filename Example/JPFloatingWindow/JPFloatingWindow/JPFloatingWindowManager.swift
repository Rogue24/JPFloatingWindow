//
//  JPFloatingWindowManager.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/3/5.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

let JPFwManager = JPFloatingWindowManager.shareIntance
let JPFwAnimator = JPFloatingWindowManager.shareIntance.animator

class JPFloatingWindowManager {

    static let shareIntance: JPFloatingWindowManager = JPFloatingWindowManager()
    
    let animator : JPFloatingWindowAnimator = JPFloatingWindowAnimator()
    
    var floatingWindows : [JPFloatingWindow] = []
    
    var floatingWindowsHasDidChanged : ((_ isInsert: Bool, _ index: Int) -> Void)?
    
    init() {
        UIPercentDrivenInteractiveTransition.jp_takeOnceTimeFunc()
        UINavigationController.jp_takeOnceTimeFunc()
    }
    
}
