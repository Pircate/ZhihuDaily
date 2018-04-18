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
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        return webView
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
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    private let viewModel = NewsDetailViewModel()
    
    static func register(parameters: [String : Any]?) -> Routable {
        return NewsDetailViewController()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigation.bar.isUnrestoredWhenViewWillLayoutSubviews = true
        navigation.bar.frame.origin.y = -24;
        navigation.bar.backgroundColor = UIColor.white
        addSubviews()
        viewModel.bindToViews(webView: webView, titleLabel: titleLabel, imageView: headerView)
        viewModel.requestNewsDetail(newsID: newsID)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private
    private func addSubviews() {
        disableAdjustsScrollViewInsets(webView.scrollView)
        view.addSubview(webView)
        webView.scrollView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalTo(UIScreen.width - 30)
        }
    }
}

// MARK: - WKNavigationDelegate
extension NewsDetailViewController: WKNavigationDelegate {
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if url == "about:blank" {
            decisionHandler(.allow)
        }
        else {
            if navigationAction.sourceFrame.isMainFrame {
                push(WebViewController.self, configuration: { (web) in
                    web.url = url ?? ""
                })
                decisionHandler(.cancel)
            }
            else {
                decisionHandler(.allow)
            }
        }
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
        navigation.bar.isHidden = scrollView.contentOffset.y < 180
        statusBarStyle = scrollView.contentOffset.y < 180 ? .lightContent : .default
        setNeedsStatusBarAppearanceUpdate()
    }
}
