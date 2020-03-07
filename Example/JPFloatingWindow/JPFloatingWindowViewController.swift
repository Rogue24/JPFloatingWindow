//
//  JPFloatingWindowViewController.swift
//  JPPresentationLayerDemo_Example
//
//  Created by 周健平 on 2020/2/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit

class JPFloatingWindowViewController: UIViewController {
    
    static let cellMargin = (jp_portraitScreenWidth_ - 4 * JPFloatingWindow.size.width) / 5.0
    
    fileprivate let uiSwitch : UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.isOn = true
        return uiSwitch
    }()
    
    fileprivate let collectionView : UICollectionView = UICollectionView(frame: jp_portraitScreenBounds_, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Floating Window List"
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(goWebVC))
        navigationItem.rightBarButtonItems = [barButtonItem, UIBarButtonItem(customView: uiSwitch)]
        
        JPFwManager.floatingWindowsHasDidChanged = { [weak self] (isInsert, index) in
            print("保存了多少个", JPFwManager.floatingWindows.count)
            self?.collectionView.performBatchUpdates({
                if isInsert == true {
                    self?.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                } else {
                    self?.collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
                }
            }, completion: nil)
        }
        
        let bgImgView = UIImageView(frame: jp_portraitScreenBounds_)
        bgImgView.image = UIImage(contentsOfFile: (Bundle.main.path(forResource: "jp_background", ofType: "jpg")!))
        bgImgView.contentMode = .scaleAspectFill
        bgImgView.clipsToBounds = true
        view.addSubview(bgImgView)
        
        let cellMargin = JPFloatingWindowViewController.cellMargin
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = JPFloatingWindow.size
        flowLayout.minimumLineSpacing = cellMargin
        flowLayout.minimumInteritemSpacing = cellMargin
        flowLayout.sectionInset = UIEdgeInsets(top: jp_navTopMargin_ + cellMargin, left: cellMargin, bottom: jp_diffTabBarH_ + cellMargin, right: cellMargin)
        
        jp_contentInsetAdjustmentNever(collectionView)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.collectionViewLayout = flowLayout
        collectionView.register(JPFloatingWindowCell.self, forCellWithReuseIdentifier: JPFloatingWindowCellID)
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
}

extension JPFloatingWindowViewController {
    @objc fileprivate func goWebVC() {
        let webVC = JPWebViewController(urlString: "https://www.bilibili.com", uiSwitch.isOn)
        navigationController?.pushViewController(webVC, animated: true)
    }
}

// MARK:- UICollectionViewDataSource
extension JPFloatingWindowViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return JPFwManager.floatingWindows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : JPFloatingWindowCell = collectionView.dequeueReusableCell(withReuseIdentifier: JPFloatingWindowCellID, for: indexPath) as! JPFloatingWindowCell
        
        return cell
    }
}

// MARK:- UICollectionViewDelegate
extension JPFloatingWindowViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let floatingWindow = JPFwManager.floatingWindows[indexPath.item]
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            let point = collectionView.convert(cell.center, to: navigationController?.view)
            floatingWindow.floatingPoint = point
        }
        
        JPFwAnimator.spreadFw = floatingWindow
        navigationController?.pushViewController(floatingWindow.floatingVC, animated: true)
    }
}
