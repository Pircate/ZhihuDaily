//
//  NewsDetailViewModel.swift
//  ZhihuDaily
//
//  Created by G-Xi0N on 2018/3/11.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import RxSwift
import RxCocoa
import Moya
import WebKit

extension Reactive where Base: WKWebView {
    
    var htmlString: Binder<String> {
        return Binder(self.base) { webView, htmlString in
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }
}

class NewsDetailViewModel {
    
    let subject: BehaviorSubject<NewsDetailModel>
    let title: Driver<String>
    let body: Driver<String>
    let image: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    init() {
        subject = BehaviorSubject(value: NewsDetailModel())
        
        title = subject.map({
            $0.title ?? ""
        }).asDriver(onErrorJustReturn: "")
        
        body = subject.map({
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <link rel="stylesheet" type="text/css" href="\($0.css?.first ?? "")">
            </head>
            <body>
            </body>
            </html>
            """
            return html.replacingOccurrences(of: "</body>", with: "\($0.body ?? "")</body>")
        }).asDriver(onErrorJustReturn: "")
        
        image = subject.map({
            $0.image ?? ""
        })
    }
    
    func requestNewsDetail(newsID: Int) {
        HomeTarget.newsDetail(newsID: newsID).request(NewsDetailModel.self).subscribe(onSuccess: { (response) in
            self.subject.onNext(response)
        }, onError: nil).disposed(by: disposeBag)
    }
    
    func bindToViews(webView: WKWebView, titleLabel: UILabel, imageView: UIImageView) {
        body.drive(webView.rx.htmlString).disposed(by: disposeBag)
        title.drive(titleLabel.rx.text).disposed(by: disposeBag)
        image.subscribeOn(MainScheduler.instance).subscribe(onNext: { (url) in
            imageView.kf.setImage(with: URL(string: url))
        }).disposed(by: disposeBag)
    }
}
