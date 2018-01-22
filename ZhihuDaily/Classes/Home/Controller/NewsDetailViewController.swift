//
//  NewsDetailViewController.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import WebKit

class NewsDetailViewController: BaseViewController, Routable {

    var newsID = ""
    
    let configuration: WKWebViewConfiguration = {
        var source = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=device-width');
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
        let webView = WKWebView(frame: view.bounds, configuration: self.configuration)
        webView.navigationDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.delegate = self
        return webView
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 2))
        progressView.progressTintColor = .green
        progressView.trackTintColor = .clear
        return progressView
    }()
    
    lazy var headerView: UIImageView = {
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 200))
        headerView.backgroundColor = UIColor.global
        return headerView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 2
        return label
    }()
    
    lazy var statusBarBackView: UIView = {
        let backView = UIView()
        backView.backgroundColor = UIColor.white
        backView.isHidden = true
        return backView
    }()
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    
    static func initializeRoute(parameters: [String : Any]?) -> Routable {
        return NewsDetailViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ay_navigationBar.isHidden = true
        addSubviews()
        requestNewsDetail()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private
    private func addObserver() {
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    private func addSubviews() {
        disableAdjustsScrollViewInsets(webView.scrollView)
        view.addSubview(webView)
        webView.scrollView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        view.addSubview(progressView)
        view.addSubview(statusBarBackView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.width - 30)
        }
        
        statusBarBackView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(UIApplication.shared.statusBarFrame.height)
        }
    }
    
    private func requestNewsDetail() {
        HomeComponent().requestNewsDetail(newsID: newsID, success: { (model) in
            if let url = model?.image {
                self.headerView.kf.setImage(with: URL(string: url))
            }
            if let title = model?.title {
                self.titleLabel.text = title
            }
            if let body = model?.body {
                var html = """
                    <!DOCTYPE html>
                    <html>
                    <head>
                      <meta charset="utf-8">
                      <link rel="stylesheet" type="text/css" href="\(model?.css?.first ?? "")">
                    </head>
                    <body>
                    </body>
                    </html>
                """
                html = html.replacingOccurrences(of: "</body>", with: "\(body)</body>")
                self.webView.loadHTMLString(html, baseURL: nil)
            }
        }) { (error) in
            
        }
    }
    
    // MARK: - observe
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            if progressView.progress == 1 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.progressView.transform = .identity
                }, completion: { (finished) in
                    self.progressView.isHidden = true
                })
            }
        }
    }
}

// MARK: - WKNavigationDelegate
extension NewsDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
        view.bringSubview(toFront: progressView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        progressView.isHidden = true
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
}

extension NewsDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            if scrollView.contentOffset.y > -60 {
                var frame = headerView.frame
                frame.origin.y = scrollView.contentOffset.y
                frame.size.height = 200 - scrollView.contentOffset.y
                headerView.frame = frame
            }
            else {
                headerView.frame = CGRect(x: 0, y: -60, width: UIScreen.width, height: 260)
                scrollView.contentOffset = CGPoint(x: 0, y: -60)
            }
        }
        statusBarBackView.isHidden = scrollView.contentOffset.y < 180
        statusBarStyle = scrollView.contentOffset.y < 180 ? .lightContent : .default
        setNeedsStatusBarAppearanceUpdate()
    }
}
