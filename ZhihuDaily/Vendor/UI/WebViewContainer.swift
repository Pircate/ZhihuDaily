//
//  WebViewContainer.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/26.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import WebKit

class WebViewContainer: UIView {
    
    let configuration: WKWebViewConfiguration = {
        var source = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width, initial-scale=1, maximum-scale=1');
            document.getElementsByTagName('head')[0].appendChild(meta);
            """
        let userScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentCtrl = WKUserContentController()
        userContentCtrl.addUserScript(userScript)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentCtrl
        return configuration
    }()
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        return webView
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 2))
        progressView.progressTintColor = .green
        progressView.trackTintColor = .clear
        progressView.isUserInteractionEnabled = false
        return progressView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        addSubviews()
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        webView.navigationDelegate = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = bounds
        progressView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 2)
    }
    
    private func addSubviews() {
        addSubview(webView)
        addSubview(progressView)
    }
    
    private func showProgressView(visible: Bool = true, animated: Bool = true) {
        UIView.animate(withDuration: 0.25) {
            self.progressView.alpha = visible ? 1 : 0
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.progressView.transform = .identity
                }, completion: { (finished) in
                    self.showProgressView(visible: false)
                })
            }
        }
    }
}

extension WebViewContainer: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showProgressView()
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        bringSubview(toFront: progressView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showProgressView(visible: false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showProgressView(visible: false)
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}
