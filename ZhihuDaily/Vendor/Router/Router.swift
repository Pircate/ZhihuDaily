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
    static func register(parameters: [String: Any]?) -> Routable
}

protocol Redirectable {
    static func redirect(route: Routable.Type, parameters: [String: Any]?, transform: @escaping (Routable) -> Void)
}

extension Redirectable {
    static func redirect(route: Routable.Type, parameters: [String: Any]?, transform: @escaping (Routable) -> Void) {
        transform(route.register(parameters: parameters))
    }
}

struct Router: Redirectable {
    
    public static func open<Route>(_ route: Route.Type,
                                   parameters: [String: Any]? = nil,
                                   from originViewController: UIViewController,
                                   animated: Bool = true,
                                   options: RouterOpenOptions = .push,
                                   configuration: ((Route) -> Void)? = nil,
                                   completion: ((UIViewController, Route) -> Void)? = nil) where Route: Routable {
        
        func configurationHandler(target: Routable, configuration: ((Route) -> Void)?) {
            guard let target = target as? Route else { return }
            configuration.map({ $0(target) })
        }
        
        func completionHandler(origin: UIViewController, target: Routable, completion: ((UIViewController, Route) -> Void)?) {
            guard let target = target as? Route else { return }
            completion.map({
                $0(origin, target)
            })
        }
        
        redirect(route: route, parameters: parameters) { (target) in
            guard let viewController = target as? UIViewController else {
                fatalError("Target type error")
            }
            switch options {
            case .push:
                configurationHandler(target: target, configuration: configuration)
                if let nav = originViewController as? UINavigationController {
                    nav.pushViewController(viewController, animated: animated)
                }
                else {
                    originViewController.navigationController.map({
                        $0.pushViewController(viewController, animated: animated)
                    })
                }
            case .present:
                configurationHandler(target: target, configuration: configuration)
                originViewController.present(viewController, animated: animated, completion: {
                    completionHandler(origin: originViewController, target: target, completion: completion)
                })
            case .presentNav:
                configurationHandler(target: target, configuration: configuration)
                let nav = UINavigationController(rootViewController: viewController)
                originViewController.present(nav, animated: animated, completion: {
                    completionHandler(origin: originViewController, target: target, completion: completion)
                })
            }
        }
    }
}

extension UIViewController {
    
    func push<T>(_ route: T.Type,
                 parameters: [String: Any]? = nil,
                 animated: Bool = true,
                 configuration: ((T) -> Void)? = nil) where T: Routable {
        Router.open(route, parameters: parameters, from: self, animated: animated, configuration: configuration, completion: nil)
    }
    
    func present<T>(_ route: T.Type,
                    parameters: [String: Any]? = nil,
                    animated: Bool = true,
                    configuration: ((T) -> Void)? = nil,
                    completion: ((UIViewController, T) -> Void)? = nil) where T: Routable {
        Router.open(route, parameters: parameters, from: self, animated: animated, options: .present, configuration: configuration, completion: completion)
    }
    
    func presentNav<T>(_ route: T.Type,
                       parameters: [String: Any]? = nil,
                       animated: Bool = true,
                       configuration: ((T) -> Void)? = nil,
                       completion: ((UIViewController, T) -> Void)? = nil) where T: Routable {
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
    
    func push<T>(_ route: T.Type,
                 parameters: [String: Any]? = nil,
                 animated: Bool = true,
                 configuration: ((T) -> Void)? = nil) where T: Routable {
        self.currentViewController()?.push(route, parameters: parameters, animated: animated, configuration: configuration)
    }
    
    func present<T>(_ route: T.Type,
                    parameters: [String: Any]? = nil,
                    animated: Bool = true,
                    configuration: ((T) -> Void)? = nil,
                    completion: ((UIViewController, T) -> Void)? = nil) where T: Routable {
        self.currentViewController()?.present(route, parameters: parameters, animated: animated, configuration: configuration, completion: completion)
    }
    
    func presentNav<T>(_ route: T.Type,
                       parameters: [String: Any]? = nil,
                       animated: Bool = true,
                       configuration: ((T) -> Void)? = nil,
                       completion: ((UIViewController, T) -> Void)? = nil) where T: Routable {
        self.currentViewController()?.presentNav(route, parameters: parameters, animated: animated, configuration: configuration, completion: completion)
    }
}
