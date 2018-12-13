//
//  AppDelegate.swift
//  ZhihuDaily
//
//  Created by 高 on 2018/1/3.
//  Copyright © 2018年 gaoX. All rights reserved.
//

import UIKit
import EachNavigationBar
import RxNetwork

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Network.Configuration.default.plugins = [NetworkIndicatorPlugin()]
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
