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
      preferredStyle: UIAlertControllerStyle = .alert,
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
    
    func dismiss(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        
        if presentingViewController != nil {
            navigationController.map({
                if $0.viewControllers.count > 1 {
                    $0.popViewController(animated: animated)
                }
                else {
                    dismiss(animated: animated, completion: completion)
                }
            })
            dismiss(animated: animated, completion: completion)
        }
        else {
            navigationController.map({
                $0.popViewController(animated: animated)
                completion.map({ $0() })
            })
        }
    }
}
