//
//  Router.swift
//  SwiftRouter
//
//  Created by G-Xi0N on 2017/12/27.
//  Copyright © 2017年 gaoX. All rights reserved.
//

import Foundation
import UIKit

enum RouterOpenOptions {
    case push, present, presentNav
}

protocol Routable {
    static func initializeRoute(parameters: [String: Any]?) -> Routable
}

protocol Interceptable {
    static func intercept(route: Routable.Type, parameters: [String: Any]?, completion: @escaping (Routable) -> Void)
}

extension Interceptable {
    
    static func intercept(route: Routable.Type, parameters: [String: Any]?, completion: @escaping (Routable) -> Void) {
        completion(route.initializeRoute(parameters: parameters))
    }
}

struct Router: Interceptable {
    
    static func open<T: Routable>(_ route: T.Type,
                                  parameters: [String: Any]?,
                                  from originViewController: UIViewController,
                                  animated: Bool,
                                  options: RouterOpenOptions = .push,
                                  configuration: ((_ route: T) -> Void)?,
                                  completion: (() -> Void)?) {
        
        func configurationHandler(target: Routable, configuration: ((_ route: T) -> Void)?) {
            guard let target = target as? T else { return }
            if let configuration = configuration {
                configuration(target)
            }
        }
        
        intercept(route: route, parameters: parameters) { (target) in
            guard let viewController = target as? UIViewController else { return }
            switch options {
            case .push:
                configurationHandler(target: target, configuration: configuration)
                if let nav = originViewController as? UINavigationController {
                    nav.pushViewController(viewController, animated: animated)
                }
                else {
                    if let nav = originViewController.navigationController {
                        nav.pushViewController(viewController, animated: animated)
                    }
                }
            case .present:
                configurationHandler(target: target, configuration: configuration)
                originViewController.present(viewController, animated: animated, completion: completion)
            case .presentNav:
                configurationHandler(target: target, configuration: configuration)
                let nav = UINavigationController(rootViewController: viewController)
                originViewController.present(nav, animated: animated, completion: completion)
            }
        }
    }
}

extension UIViewController {
    
    func push<T: Routable>(_ route: T.Type,
                           parameters: [String: Any]? = nil,
                           animated: Bool = true,
                           configuration: ((_ route: T) -> Void)? = nil) {
        Router.open(route, parameters: parameters, from: self, animated: animated, configuration: configuration, completion: nil)
    }
    
    func present<T: Routable>(_ route: T.Type,
                              parameters: [String: Any]? = nil,
                              animated: Bool = true,
                              configuration: ((_ route: T) -> Void)? = nil,
                              completion: (() -> Void)?) {
        Router.open(route, parameters: parameters, from: self, animated: animated, options: .present, configuration: configuration, completion: completion)
    }
    
    func presentNav<T: Routable>(_ route: T.Type,
                                 parameters: [String: Any]? = nil,
                                 animated: Bool = true,
                                 configuration: ((_ route: T) -> Void)? = nil,
                                 completion: (() -> Void)?) {
        Router.open(route, parameters: parameters, from: self, animated: animated, options: .presentNav, configuration: configuration, completion: completion)
    }
}

extension UIView {
    
    public func currentViewController() -> UIViewController? {
        var next = superview
        while next != nil {
            let nextResponder = next?.next
            if nextResponder is UIViewController {
                return nextResponder as? UIViewController
            }
            next = next?.superview
        }
        return nil
    }
    
    func push<T: Routable>(_ route: T.Type,
                           parameters: [String: Any]? = nil,
                           animated: Bool = true,
                           configuration: ((_ route: T) -> Void)? = nil) {
        self.currentViewController()?.push(route, parameters: parameters, animated: animated, configuration: configuration)
    }
    
    func present<T: Routable>(_ route: T.Type,
                              parameters: [String: Any]? = nil,
                              animated: Bool = true,
                              configuration: ((_ route: T) -> Void)? = nil,
                              completion: (() -> Void)?) {
        self.currentViewController()?.present(route, parameters: parameters, animated: animated, configuration: configuration, completion: completion)
    }
    
    func presentNav<T: Routable>(_ route: T.Type,
                                 parameters: [String: Any]? = nil,
                                 animated: Bool = true,
                                 configuration: ((_ route: T) -> Void)? = nil,
                                 completion: (() -> Void)?) {
        self.currentViewController()?.presentNav(route, parameters: parameters, animated: animated, configuration: configuration, completion: completion)
    }
}

