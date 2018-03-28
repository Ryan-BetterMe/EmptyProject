//
//  AppDelegate.swift
//  EmptyProject
//
//  Created by 向辉 on 2018/3/26.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        initAnalysis(application, launchOptions: launchOptions)
        initNetAndPurchase()
        initMainView()
        
        return true
    }
}

extension AppDelegate {
    
    /// 初始化三方统计
    func initAnalysis(_ application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Void {
        
        AnalysisTool.sharedInstance.startAnalysis(withApplication: application, withLaunchOptions: launchOptions, logEnabled: true)
    }
    
    /// 初始化内购和网络
    func initNetAndPurchase() {
        IAPManager.shareInstance.secret = IAPInfomation.subscriptionSecret
        IAPManager.shareInstance.completeTransaction()
    }
    
    /// 初始化主界面
    func initMainView() {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.clear
        
        let navigationVC = UINavigationController.init(rootViewController: MainViewController())
        navigationVC.setNavigationBarHidden(true, animated: false)
        
        window?.rootViewController = navigationVC
        window?.makeKeyAndVisible()
    }
}
