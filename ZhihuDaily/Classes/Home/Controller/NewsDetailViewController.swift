//
//  NewsDetailViewController.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/22.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import WebKit

final class NewsDetailViewController: BaseViewController {

    var newsID = ""
    
    var heroID: String? {
        didSet {
            headerView.hero.id = heroID
        }
    }
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        return webView
    }()
    
    lazy var headerView: UIImageView = {
        UIImageView().chain
            .frame(x: 0, y: 0, width: UIScreen.width, height: 200)
            .backgroundColor(UIColor.global).build
    }()
    
    lazy var titleLabel: UILabel = {
        UILabel().chain
            .textColor(UIColor.white)
            .systemFont(ofSize: 18)
            .numberOfLines(2).build
    }()
    
    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigation.bar.isUnrestoredWhenViewWillLayoutSubviews = true
        navigation.bar.frame.origin.y = -24;
        navigation.bar.backgroundColor = UIColor.white
        addSubviews()
        bindViewModel()
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
    
    private func bindViewModel() {
        let viewModel = NewsDetailViewModel()
        let refresh = Observable.just(newsID)
        let input = NewsDetailViewModel.Input(refresh: refresh)
        let output = viewModel.transform(input)
        
        output.title.drive(titleLabel.rx.text).disposed(by: disposeBag)
        output.body.drive(webView.rx.htmlString).disposed(by: disposeBag)
        output.image.drive(headerView.rx.webImage).disposed(by: disposeBag)
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
                if let url = url {
                    push(WebViewController.self) {
                        $0.loadURL(url)
                    }
                }
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
        navigationController?.navigationBar.barStyle = scrollView.contentOffset.y < 180 ? .black : .default
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension NewsDetailViewController: Navigatable {
    
    func start(_ closure: (NewsDetailViewController) -> Void = { _ in }) {
        closure(self)
        navigator?.pushViewController(self, animated: true)
    }
}
