//
//  WebViewController.swift
//  iWeeB
//
//  Created by 高翔 on 2017/12/1.
//  Copyright © 2017年 GaoX. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, Routable {
    static func initializeRoute(parameters: [String : Any]?) -> Routable {
        return WebViewController()
    }
    
    // MARK: - properties
    var url = ""
    var HTMLString = ""
    
    lazy var container: WebViewContainer = {
        let container = WebViewContainer()
        return container
    }()
    
    lazy var backButton: UIButton = {
        let backBtn = UIButton(type: .system)
        backBtn.frame = CGRect(x: 0, y: 0, width: 48, height: 44)
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(.white, for: .normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        return backBtn
    }()
    
    lazy var closeButton: UIButton = {
        let closeBtn = UIButton(type: .system)
        closeBtn.frame = CGRect(x: 0, y: 0, width: 36, height: 44)
        closeBtn.setTitle("关闭", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        return closeBtn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        updateLeftNavigationBarItem()
        addObserver()
        addSubviews()

        if !url.isEmpty {
            loadURLRequest()
        }
        else if !HTMLString.isEmpty {
            loadHTMLString()
        }
        else {
            loadFail()
        }
    }
    
    deinit {
        if view.subviews.contains(container) {
            container.webView.removeObserver(self, forKeyPath: "title")
            container.webView.removeObserver(self, forKeyPath: "canGoBack")
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - private
    private func addObserver() {
        container.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        container.webView.addObserver(self, forKeyPath: "canGoBack", options: .new, context: nil)
    }
    
    private func addSubviews() {
        registerNavigationBar()
        ay_navigationBar.backgroundColor = UIColor.global
        ay_navigationItem.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        view.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.top.equalTo(ay_navigationBar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func updateLeftNavigationBarItem() {
        if container.webView.canGoBack {
            ay_navigationItem.leftBarItems = [backButton, closeButton]
        }
        else {
            ay_navigationItem.leftBarButton = backButton
        }
    }
    
    private func loadURLRequest() {
        if url.isEmpty {
            loadFail()
            return
        }
        do {
            let dataDetector = try NSDataDetector(types: NSTextCheckingTypes(NSTextCheckingResult.CheckingType.link.rawValue))
            let result = dataDetector.firstMatch(in: url, options: .reportCompletion, range: NSMakeRange(0, url.count))
            if let URL = result?.url {
                container.webView.load(URLRequest(url: URL))
            }
            else {
                loadFail()
            }
        } catch {
            loadFail()
        }
    }
    
    private func loadHTMLString() {
        container.webView.loadHTMLString(HTMLString, baseURL: nil)
    }
    
    private func loadFail() {
        ay_navigationItem.title = "很抱歉，加载失败"
    }
    
    // MARK: - observe
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            ay_navigationItem.title = container.webView.title
        }
        if keyPath == "canGoBack" {
            updateLeftNavigationBarItem()
        }
    }
    
    // MARK: - action
    @objc private func backBtnAction() {
        if container.webView.canGoBack {
            container.webView.goBack()
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func closeBtnAction() {
        navigationController?.popViewController(animated: true)
    }
}
