//
//  JPFloatingWindowProtocol.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/3/3.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

// 需要浮窗的协议
protocol JPFloatingWindowProtocol : UIViewController {
    var jp_isFloatingEnabled : Bool {set get}
    
    func jp_navigationController(_ navCtr: UINavigationController, animationWillBeginFor isPush: Bool, from fromVC: UIViewController, to toVC: UIViewController)
    
    func jp_navigationController(_ navCtr: UINavigationController, animationCanceledFor isPush: Bool, from fromVC: UIViewController, to toVC: UIViewController)
    
    func jp_navigationController(_ navCtr: UINavigationController, animationEndedFor isPush: Bool, from fromVC: UIViewController, to toVC: UIViewController)
}
