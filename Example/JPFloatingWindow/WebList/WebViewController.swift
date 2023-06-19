//
//  WebViewController.swift
//  JPFloatingWindow
//
//  Created by 周健平 on 2020/3/3.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
import Combine

class WebViewController: UIViewController, JPFloatingWindowProtocol {
    var jp_isFloatingEnabled: Bool = JPFloatingWindowSwitch.shared.isOn
    
    var urlString : String? {
        set { url = newValue.map { URL(string: $0) } ?? nil }
        get { url?.absoluteString }
    }
    fileprivate var url : URL?
    
    fileprivate var cancellable: AnyCancellable?
    
    init(urlString: String?) {
        super.init(nibName: nil, bundle: nil)
        self.urlString = urlString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate let webView : WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.suppressesIncrementalRendering = false
        configuration.allowsInlineMediaPlayback = false
        configuration.allowsAirPlayForMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        
        let webView = WKWebView(frame: jp_portraitScreenBounds_, configuration: configuration)
        webView.backgroundColor = UIColor.secondarySystemBackground
        webView.scrollView.backgroundColor = UIColor.white
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.alwaysBounceVertical = true
        webView.scrollView.contentInset = UIEdgeInsets(top: jp_navTopMargin_, left: 0, bottom: jp_diffTabBarH_, right: 0);
        webView.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: jp_navBarH_, left: 0, bottom: 0, right: 0)
        webView.alpha = 0
        return webView
    }()
    
    fileprivate let progressView : UIProgressView = UIProgressView()
    
    fileprivate let naviBgView : UIView = {
        let naviBar = UIView(frame: CGRect(x: 0, y: 0, width: jp_portraitScreenWidth_, height: jp_navTopMargin_))
        naviBar.backgroundColor = UIColor.tertiarySystemBackground
        return naviBar
    }()
    
    fileprivate let floatingEnableBtn : UIButton = {
        let floatingEnableBtn = UIButton(type: .system)
        floatingEnableBtn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return floatingEnableBtn
    }()
    
    fileprivate let reloadBtn : UIButton = {
        let reloadBtn = UIButton(type: .system)
        reloadBtn.setImage(UIImage(named: "jp_icon_refresh"), for: .normal)
        return reloadBtn
    }()
    
    
    fileprivate let backBtn : UIButton = {
        let backBtn = UIButton(type: .system)
        backBtn.setImage(UIImage(named: "jp_icon_back"), for: .normal)
        backBtn.isUserInteractionEnabled = false
        backBtn.alpha = 0.3
        return backBtn
    }()
    
    fileprivate let forwardBtn : UIButton = {
        let forwardBtn = UIButton(type: .system)
        forwardBtn.setImage(UIImage(named: "jp_icon_back"), for: .normal)
        forwardBtn.isUserInteractionEnabled = false
        forwardBtn.alpha = 0.3
        return forwardBtn
    }()
    
    fileprivate let bottomView : UIVisualEffectView = {
        let bottomView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        bottomView.frame = CGRect(x: 0, y: jp_portraitScreenHeight_, width: jp_portraitScreenWidth_, height: jp_tabBarH_)
        return bottomView
    }()
    
    fileprivate var isProgressing : Bool = false {
        willSet {
            guard isProgressing != newValue else {
                return
            }
            backBtn.isUserInteractionEnabled = webView.canGoBack;
            UIView.animate(withDuration: 0.15) {
                self.progressView.alpha = newValue == true ? 1 : 0
            }
        }
    }
    
    fileprivate var isCanGoBack : Bool = false {
        willSet {
            guard isCanGoBack != newValue else {
                return
            }
            backBtn.isUserInteractionEnabled = newValue
            UIView.animate(withDuration: 0.13) {
                self.backBtn.alpha = newValue == true ? 1 : 0.3
            }
        }
    }
    
    fileprivate var isCanGoForward : Bool = false {
        willSet {
            guard isCanGoForward != newValue else {
                return
            }
            forwardBtn.isUserInteractionEnabled = newValue
            UIView.animate(withDuration: 0.13) {
                self.forwardBtn.alpha = newValue == true ? 1 : 0.3
            }
        }
    }
    
    fileprivate var isCanGoBackOrForward : Bool = false {
        willSet {
            guard isCanGoBackOrForward != newValue else {
                return
            }
            
            bottomView.isUserInteractionEnabled = newValue
            
            var contentInset = webView.scrollView.contentInset
            contentInset.bottom = newValue ? jp_tabBarH_ : jp_diffTabBarH_
            
            var scrollIndicatorInsets = webView.scrollView.verticalScrollIndicatorInsets
            scrollIndicatorInsets.bottom = newValue ? jp_baseTabBarH_ : 0;
            
            let y = jp_portraitScreenHeight_ - (newValue ? jp_tabBarH_ : 0)
            
            UIView.animate(withDuration: 0.13) {
                self.webView.scrollView.contentInset = contentInset
                self.webView.scrollView.verticalScrollIndicatorInsets = scrollIndicatorInsets
                self.bottomView.frame.origin.y = y
            }
        }
    }
    
    var isRequested : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebViewObserver(isRemove: false)
        cancellable = JPFloatingWindowSwitch.shared.$isOn
            .removeDuplicates()
            .sink { [weak self] isOn in
                self?.floatingEnableBtn.setImage(UIImage(named: isOn ? "jp_icon_circle" : "jp_icon_circle_delete"), for: .normal)
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        jp_isFloatingEnabled = JPFloatingWindowSwitch.shared.isOn
        
        guard isRequested == false, let URL = self.url else {
            return
        }
        webView.load(URLRequest(url: URL))
        isRequested = true
    }
    
    deinit {
        print("WebViewController壮烈牺牲")
        setupWebViewObserver(isRemove: true)
        cancellable?.cancel()
    }
}

// MARK: - UI布局
extension WebViewController {
    fileprivate func setupUI() {
        title = "加载中..."
        view.backgroundColor = webView.backgroundColor
        
        webView.navigationDelegate = self
        jp_contentInsetAdjustmentNever(webView.scrollView)
        view.addSubview(webView)
        
        view.addSubview(naviBgView)
        
        progressView.trackTintColor = UIColor.clear
        progressView.frame = CGRect(x: 0, y: naviBgView.frame.maxY, width: jp_portraitScreenWidth_, height: progressView.frame.height)
        view.addSubview(progressView)
        
        let btnSize : CGSize = CGSize(width: 44, height: 44)
        
        reloadBtn.frame = CGRect(origin: CGPoint.zero, size: btnSize)
        floatingEnableBtn.frame = reloadBtn.frame
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: reloadBtn), UIBarButtonItem(customView: floatingEnableBtn)]
        
        backBtn.frame = reloadBtn.frame
        backBtn.center = CGPoint(x: jp_portraitScreenWidth_ * 0.25, y: jp_baseTabBarH_ * 0.5)
        bottomView.contentView.addSubview(backBtn)
        
        forwardBtn.frame = backBtn.frame
        forwardBtn.center = CGPoint(x: jp_portraitScreenWidth_ * 0.75, y: jp_baseTabBarH_ * 0.5)
        forwardBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        bottomView.contentView.addSubview(forwardBtn)
        
        view.addSubview(bottomView)
        
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        forwardBtn.addTarget(self, action: #selector(forward), for: .touchUpInside)
        reloadBtn.addTarget(self, action: #selector(reloadWeb), for: .touchUpInside)
        floatingEnableBtn.addTarget(self, action: #selector(floatingEnable), for: .touchUpInside)
    }
}

// MARK: - KVO
extension WebViewController {
    fileprivate func setupWebViewObserver(isRemove: Bool) {
        if (isRemove) {
            webView.removeObserver(self, forKeyPath: "title")
            webView.removeObserver(self, forKeyPath: "canGoBack")
            webView.removeObserver(self, forKeyPath: "canGoForward")
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
        } else {
            webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
            webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
            webView.addObserver(self, forKeyPath: "canGoForward", options: .new, context: nil)
            webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        title = webView.title ?? "加载中..."
        progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        isProgressing = webView.estimatedProgress < 1
        isCanGoBack = webView.canGoBack
        isCanGoForward = webView.canGoForward
        isCanGoBackOrForward = webView.canGoBack
    }
}

// MARK: - 按钮事件
fileprivate extension WebViewController {
    @objc func back() {
        guard webView.canGoBack else { return }
        webView.goBack()
    }
    
    @objc func forward() {
        guard webView.canGoForward else { return }
        webView.goForward()
    }
    
    @objc func reloadWeb() {
        guard url != nil else { return }
        UIView.animate(withDuration: 1.0) {
            self.reloadBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
        webView.reload()
    }
    
    @objc func floatingEnable() {
        JPFloatingWindowSwitch.shared.isOn.toggle()
        jp_isFloatingEnabled = JPFloatingWindowSwitch.shared.isOn
    }
}

// MARK: - <WKNavigationDelegate>
extension WebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIView.animate(withDuration: 0.8) {
            webView.alpha = 1
        }
    }
}

// MARK: - <JPFloatingWindowProtocol>
extension WebViewController {
    
    func jp_navigationController(_ navCtr: UINavigationController, animationWillBeginFor isPush: Bool, from fromVC: UIViewController, to toVC: UIViewController) {
        guard let navBgView = navCtr.navigationBar.jp_navBgView else {
            return
        }
        let targetVC = isPush == true ? fromVC : toVC
        if let targetVC = targetVC as? JPFloatingWindowProtocol, targetVC.jp_isFloatingEnabled == true {
            return
        }
        targetVC.view.addSubview(navBgView)
    }
    
    func jp_navigationController(_ navCtr: UINavigationController, animationCanceledFor isPush: Bool, from fromVC: UIViewController, to toVC: UIViewController) {
//        guard let navBgView = navCtr.navigationBar.jp_navBgView else {
//            return
//        }
    }
    
    func jp_navigationController(_ navCtr: UINavigationController, animationEndedFor isPush: Bool, from fromVC: UIViewController, to toVC: UIViewController) {
        guard let navBgView = navCtr.navigationBar.jp_navBgView else {
            return
        }
        if let toVC = toVC as? JPFloatingWindowProtocol, toVC.jp_isFloatingEnabled == true {
            return
        }
        navCtr.navigationBar.jp_setupCustomNavigationBgView(customBgView: navBgView)
    }
    
}
