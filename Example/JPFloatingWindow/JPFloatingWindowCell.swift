//
//  JPFloatingWindowCell.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/3/5.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

let JPFloatingWindowCellID = "JPFloatingWindowCell"

class JPFloatingWindowCell: UICollectionViewCell {
    let fwIcon : UIImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: JPFloatingWindow.size))
//    let fwLabel :
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        fwIcon.image = UIImage(named: "jp_web_icon")
        fwIcon.layer.cornerRadius = 16
        fwIcon.layer.masksToBounds = true
        addSubview(fwIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
