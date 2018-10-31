//
//  UIViewControllerExtension.swift
//  iWeeB
//
//  Created by 高翔 on 2017/12/4.
//  Copyright © 2017年 GaoX. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func disableAdjustsScrollViewInsets(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func alert(title: String?,
             message: String?,
      preferredStyle: UIAlertController.Style = .alert,
         cancelTitle: String?,
         otherTitles: [String],
   completionHandler: @escaping (_ buttonIndex: Int) -> ()) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if let title = cancelTitle {
            alert.addAction(UIAlertAction(title: title, style: .cancel, handler: { (action) in
                completionHandler(0)
            }))
        }
        
        if !otherTitles.isEmpty {
            for (index, title) in otherTitles.enumerated() {
                alert.addAction(UIAlertAction(title: title, style: .default, handler: { (action) in
                    completionHandler(index + 1)
                }))
            }
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func push<T: UIViewController>(_ type: T.Type, animated: Bool = true, configuration: (T) -> Void = { _ in }) {
        let viewController = type.init()
        configuration(viewController)
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func goBack(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard presentingViewController != nil else {
            navigationController?.popViewController(animated: animated)
            return
        }
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: animated)
            return
        }
        dismiss(animated: animated, completion: completion)
    }
}
