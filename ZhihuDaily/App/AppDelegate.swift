//
//  AppDelegate.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/3.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import EachNavigationBar
import RxSwiftX

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Network.default.plugins = [NetworkIndicatorPlugin()]
        UIViewController.setupNavigationBar
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        let nav = UINavigationController(rootViewController: MainViewController())
        nav.navigation.configuration.isEnabled = true
        nav.navigationBar.barStyle = .black
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        return true
    }
}
