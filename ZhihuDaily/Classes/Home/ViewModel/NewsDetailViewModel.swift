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
    
    struct Input {
        let refresh: Observable<String>
    }
    
    struct Output {
        let title: Driver<String>
        let body: Driver<String>
        let image: Driver<String>
    }
    
    func transform(_ input: Input) -> Output {
        let response = input.refresh.flatMap {
            HomeTarget.newsDetail(newsID: $0).request(NewsDetailModel.self)
        }.share(replay: 1)
        
        let title = response.map({ $0.title ?? "" }).asDriver(onErrorJustReturn: "")
        let image = response.map({ $0.image ?? ""}).asDriver(onErrorJustReturn: "")
        let body = response.map({ model -> String in
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <link rel="stylesheet" type="text/css" href="\(model.css?.first ?? "")">
            </head>
            <body>
            </body>
            </html>
            """
            return html.replacingOccurrences(of: "</body>", with: "\(model.body ?? "")</body>")
        }).asDriver(onErrorJustReturn: "")
        return Output(title: title, body: body, image: image)
    }
}
