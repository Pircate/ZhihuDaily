//
//  WebViewController.swift
//  iWeeB
//
//  Created by 高翔 on 2017/12/1.
//  Copyright © 2017年 GaoX. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    // MARK: - properties
    var url = ""
    var HTMLString = ""
    
    lazy var container: WebViewContainer = {
        let container = WebViewContainer()
        return container
    }()
    
    lazy var backButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(backBtnAction))
    }()
    
    lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeBtnAction))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        disableAdjustsScrollViewInsets(container.webView.scrollView)
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
        navigation.bar.chain
            .barTintColor(UIColor.global)
            .titleTextAttributes([.foregroundColor: UIColor.white])
            .tintColor(UIColor.white)
        
        view.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.top.equalTo(navigation.bar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    private func updateLeftNavigationBarItem() {
        if container.webView.canGoBack {
            navigation.item.leftBarButtonItems = [backButton, closeButton]
        }
        else {
            navigation.item.leftBarButtonItem = backButton
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
        navigation.item.title = "很抱歉，加载失败"
    }
    
    // MARK: - observe
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            navigation.item.title = container.webView.title
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
