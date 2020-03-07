//
//  JPFloatingDecideView.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/3/3.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class JPFloatingDecideView: UIView {
    
    fileprivate var _isDecideDelete : Bool = false
    var isDecideDelete : Bool {
        set {
            if _isDecideDelete == newValue {
                return
            }
            _isDecideDelete = newValue
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if (_isDecideDelete) {
                iconView.image = UIImage(named: "circle_delete")
                titleLabel.text = "取消浮窗"
                deleteBgLayer.isHidden = false
                effectView.isHidden = true
                titleLabel.textColor = UIColor.white
            } else {
                iconView.image = UIImage(named: "circle_little")
                titleLabel.text = "浮窗"
                deleteBgLayer.isHidden = true
                effectView.isHidden = false
                effectView.layer.backgroundColor = UIColor.clear.cgColor
                titleLabel.textColor = UIColor.lightGray
            }
            CATransaction.commit()
        }
        get {
            return _isDecideDelete
        }
    }

    fileprivate var _showPersent : CGFloat = 0
    var showPersent : CGFloat {
        set {
            guard superview != nil else {return}
            
            var newPersent = newValue
            if newPersent < 0 {newPersent = 0}
            if newPersent > 1 {newPersent = 1}
            if _showPersent == newPersent {return}
            _showPersent = newPersent
            if _showPersent < 1 {
                isTouching = false
            }
            
            let scale = 1.0 - _showPersent
            center = CGPoint(x: showCenter.x + diagonalLength * scale,
                             y: showCenter.y + diagonalLength * scale)
        }
        get {
            return _showPersent
        }
    }
    
    fileprivate var _touchPoint : CGPoint = CGPoint.zero
    var touchPoint : CGPoint {
        set {
            guard superview != nil else {return}
            
            if _showPersent < 1 {
                isTouching = false
                return
            }
            
            _touchPoint = newValue
            // 计算点击的位置距离圆心的距离
            let distance : CGFloat = sqrt(pow(showCenter.x - _touchPoint.x, 2) + pow(showCenter.y - _touchPoint.y, 2))
            // 判定圆形区域之外
            isTouching = distance <= radius
        }
        get {
            return _touchPoint
        }
    }
    
    fileprivate var _isTouching : Bool = false
    fileprivate(set) public var isTouching : Bool {
        set {
            if _isTouching == newValue {return}
            _isTouching = newValue
            touchStateDidChangedAnimation(touchingNow: true)
        }
        get {
            return _isTouching
        }
    }
    
    fileprivate var showCenter : CGPoint = CGPoint.zero
    
    fileprivate let radius : CGFloat
    fileprivate let diagonalLength : CGFloat
    fileprivate let effectView : UIVisualEffectView
    fileprivate let deleteBgLayer : CALayer
    fileprivate let iconView : UIImageView
    fileprivate let titleLabel : UILabel
    fileprivate let fbGenerator : UIImpactFeedbackGenerator
    
    init() {
        radius = 160.0
        diagonalLength = sqrt(pow(radius, 2) * 0.5)
        
        effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.layer.cornerRadius = radius
        effectView.layer.masksToBounds = true
        effectView.layer.backgroundColor = UIColor.clear.cgColor
        
        deleteBgLayer = CALayer()
        deleteBgLayer.backgroundColor = UIColor(r: 232.0, g: 81.0, b: 83.0).cgColor
        deleteBgLayer.cornerRadius = radius
        deleteBgLayer.masksToBounds = true
        deleteBgLayer.isHidden = true
        
        iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        iconView.image = UIImage(named: "circle_little")
        iconView.contentMode = .center
        iconView.clipsToBounds = false
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.lightGray
        titleLabel.text = "浮窗"
        titleLabel.sizeToFit()
        
        fbGenerator = UIImpactFeedbackGenerator(style: .light)
        
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        isUserInteractionEnabled = false
        
        effectView.frame = bounds
        deleteBgLayer.frame = bounds
        iconView.center = CGPoint(x: 78.0 + iconView.frame.width * 0.5,
                                  y: 60.0 + iconView.frame.height * 0.5)
        titleLabel.center = CGPoint(x: iconView.center.x,
                                    y: iconView.frame.maxY + 10.0 + titleLabel.frame.height * 0.5)
        
        addSubview(effectView)
        layer.addSublayer(deleteBgLayer)
        addSubview(iconView)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else {
            return
        }
        
        showCenter = CGPoint(x: superview.bounds.size.width, y: superview.bounds.size.height)
        
        _showPersent = 0
        center = CGPoint(x: showCenter.x + diagonalLength, y: showCenter.y + diagonalLength)
        
        _touchPoint = CGPoint.zero
        isTouching = false
    }

}

extension JPFloatingDecideView {
    
//    func show() {
//        _showPersent = 1.0
//        _isTouching = false
//        
//        UIView.animate(withDuration: 0.25) {
//            self.center = self.showCenter
//        }
//    }

    func decideDoneAnimation(_ floatingWindow: JPFloatingWindow? = nil) {
        if _showPersent == 0 {return}
        
        _showPersent = 0.0
        _isTouching = false
        
        if let floatingWindow = floatingWindow {
            if let superview = floatingWindow.superview {
                floatingWindow.frame = superview.convert(floatingWindow.frame, to: self)
            } else {
                floatingWindow.frame = floatingWindow.convert(floatingWindow.bounds, to: self)
            }
            addSubview(floatingWindow)
        }
        
        touchStateDidChangedAnimation(touchingNow: false, animations: {
            self.center = CGPoint(x: self.showCenter.x + self.diagonalLength, y: self.showCenter.y + self.diagonalLength)
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
    
    fileprivate func touchStateDidChangedAnimation(touchingNow: Bool, animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        let scale : CGFloat = _isTouching ? 1.1 : 1.0
        let transform = CATransform3DMakeScale(scale, scale, 1)

        if touchingNow {
            fbGenerator.prepare()
            fbGenerator.impactOccurred()
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            animations?()
            
            self.effectView.layer.transform = transform
            self.deleteBgLayer.transform = transform
            self.iconView.layer.transform = transform

            if self.isDecideDelete == false {
                if self._isTouching == true {
                    self.effectView.layer.backgroundColor = UIColor.darkGray.cgColor
                    self.iconView.image = UIImage(named: "circle_big")
                    self.iconView.center = CGPoint(x: 68.0 + self.iconView.frame.width * 0.5,
                                                   y: 50.0 + self.iconView.frame.height * 0.5)
                    self.titleLabel.center = CGPoint(x: self.iconView.center.x,
                                                     y: self.iconView.frame.maxY + 15.0 + self.titleLabel.frame.height * 0.5)
                } else {
                    self.effectView.layer.backgroundColor = UIColor.clear.cgColor
                    self.iconView.image = UIImage(named: "circle_little")
                    self.iconView.center = CGPoint(x: 78.0 + self.iconView.frame.width * 0.5,
                                                   y: 60.0 + self.iconView.frame.height * 0.5)
                    self.titleLabel.center = CGPoint(x: self.iconView.center.x,
                                                     y: self.iconView.frame.maxY + 10.0 + self.titleLabel.frame.height * 0.5)
                }
            }
        }) { (finished) in
            completion?(finished)
        }
    }

}
