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
        
        if #available(iOS 13.0, *) {
            let navBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            navBar.frame = CGRect(x: 0, y: 0, width: jp_portraitScreenWidth_, height: jp_navTopMargin_)
            navigationController?.navigationBar.jp_setupCustomNavigationBgView(customBgView: navBar)
        } else {
            let navBar = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
            navBar.frame = CGRect(x: 0, y: 0, width: jp_portraitScreenWidth_, height: jp_navTopMargin_)
            navigationController?.navigationBar.jp_setupCustomNavigationBgView(customBgView: navBar)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goPlay(_ sender: Any) {
        navigationController?.pushViewController(JPFloatingWindowViewController(), animated: true)
    }
}

