//
//  ViewController.swift
//  JPFloatingWindow
//
//  Created by zhoujianping24@hotmail.com on 03/07/2020.
//  Copyright (c) 2020 zhoujianping24@hotmail.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "首页"
        
        let navBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        navBar.frame = CGRect(x: 0, y: 0, width: jp_portraitScreenWidth_, height: jp_navTopMargin_)
        navigationController?.navigationBar.jp_setupCustomNavigationBgView(customBgView: navBar)
    }

    @IBAction func goPlay(_ sender: Any) {
        navigationController?.pushViewController(WebListViewController(), animated: true)
    }
}

