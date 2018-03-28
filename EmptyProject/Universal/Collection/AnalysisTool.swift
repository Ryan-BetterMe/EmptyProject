//
//  AnalysisTool.swift
//  EmptyProject
//
//  Created by 向辉 on 2018/3/27.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//

/* Fabric
    1、在fabric后台添加新App
    2、项目导航 -> Build Phase --> Add a new run script
    3、项目导航 -> Info.plist -> Open as -> Sorce code --> Add the API key
*/

/* Facebook
    1、Configure Info.plist
 */

/* Firebase
    1、在控制台中创建一个Firebase项目（项目中可以含有很多的App）
    2、在项目中添加APP，注意，添加App的时候要注意填写包名1、Configure
    3、导入GoogleService-Info.plist 文件
    4、application:didFinishLaunchingWithOptions:中加入FirebaseApp.configure()
 */

import Foundation
import Fabric
import Crashlytics
import FacebookCore
import Firebase

public class AnalysisTool {

    /// 是否记录facebook事件
    public var fbEventEnabled = true

    /// 是否记录facebook普通事件, facebook内购事件保持打开，在fbEventEnabled为true时才有意义
    public var fbNormalEventEnabled = true
    
    /// 是否开始记录统计事件，用于区分debug/release模式
    private var logEnabled = true
    
    public static let sharedInstance = AnalysisTool()
    
    private init() {}
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
}

// MARK:- public methods
public extension AnalysisTool {
    
    /// 初始化事件统计，在AppDelegate的didFinishLaunchingWithOptions里调用
    ///
    /// - Parameters:
    ///   - application: didFinishLaunchingWithOptions中的application
    ///   - launchOptions: didFinishLaunchingWithOptions中的launchOptions
    ///   - logEnabled: 是否记录事件
    public func startAnalysis(withApplication application: UIApplication,
                              withLaunchOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
                              logEnabled: Bool) {
        
        self.logEnabled = logEnabled
        
        Fabric.with([Crashlytics.self, Answers.self])
        
        FirebaseApp.configure()
        
        if fbEventEnabled {
            SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
            
            // 打开进入前台事件监听
            NotificationCenter.default.addObserver(self, selector:#selector(applicationDidBecomeActive(notification:)),
                                                   name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        }
    }
    
    /// 记录事件
    ///
    /// - Parameters:
    ///   - event: 事件名称
    public func logEvent(event: String)  {
        
        guard logEnabled else { return }
        
        // fabric事件
        Answers.logCustomEvent(withName: event, customAttributes: nil)
        
        // firebase事件
        Analytics.logEvent(event, parameters: nil)
        
        // facebook事件
        if fbEventEnabled && fbNormalEventEnabled {
            AppEventsLogger.log(event)
        }
    }
    
    /// 记录事件
    ///
    /// - Parameters:
    ///   - event: 事件名称
    ///   - parameters: 事件参数
    public func logEventWithParameters(event: String, parameters: Dictionary<String, Any>) {
        
        guard logEnabled else { return }
        
        // fabric事件
        Answers.logCustomEvent(withName: event, customAttributes: parameters)
        
        // firebase事件
        Analytics.logEvent(event, parameters: parameters)
        
        // facebook事件
        if fbEventEnabled && fbNormalEventEnabled {
            AppEventsLogger.log(event)
        }
    }
    
    /// 记录内购事件
    ///
    /// - Parameters:
    ///   - price: 价格
    ///   - currency: 币种
    ///   - identifier: 商品ID
    ///   - name: 商品名
    ///   - description: 商品描述
    public func logIAPEvent(price: Double, currency: String, identifier: String, name: String, description: String) {
        
        guard logEnabled else { return }
        
        logPurchaseEvent(price: price, currency: currency, identifier: identifier, name: name, description: description)
    }
}

// MARK:- event response methos
private extension AnalysisTool {
    
    /// 追踪APP打开
    ///
    /// - Parameters:
    ///   - notification: 通知详情
    @objc private func applicationDidBecomeActive(notification: NSNotification) -> Void {
        
        guard logEnabled else { return }
        
        if fbEventEnabled {
            if let application = (notification.object as? UIApplication) {
                AppEventsLogger.activate(application)
            }
        }
    }
    
}

// MARK:- private methos
private extension AnalysisTool {
    
    /// 记录内购事件
    private func logPurchaseEvent(price: Double, currency: String, identifier: String, name: String, description: String) {
        let allName = "purchase_in_app_all"
        let singleName = "purchase_" + identifier.replacingOccurrences(of: ".", with: "_")
        let priceString = String.init(format: "%.2f", price)
        let identifier = identifier.replacingOccurrences(of: ".", with: "_")
        
        // fabric
        let paraDic = ["price" : priceString,
                       "currency" : currency,
                       "productName" : description,
                       "productId" : identifier] as [String : Any]
        
        Answers.logCustomEvent(withName: allName, customAttributes: paraDic)
        Answers.logCustomEvent(withName: singleName, customAttributes: paraDic)
        Answers.logPurchase(withPrice: NSDecimalNumber(value: price),
                            currency: currency,
                            success: true,
                            itemName: name,
                            itemType: description,
                            itemId: identifier,
                            customAttributes: [:])
        
        if fbEventEnabled {
            // Facebook
            let fbparams : AppEvent.ParametersDictionary = [
                .currency : currency ,
                .contentType : description ,
                .contentId : identifier]
            
            let allEvent = AppEvent(name: allName, parameters: fbparams, valueToSum: price)
            let singleEvent = AppEvent(name: singleName, parameters: fbparams, valueToSum: price)
            
            AppEventsLogger.log(.purchased(amount: price, currency: currency, extraParameters: fbparams))
            AppEventsLogger.log(allEvent)
            AppEventsLogger.log(singleEvent)
        }
        
        // FireBase
        let fireBaseDic = [AnalyticsParameterValue: NSNumber.init(value: price),
                           AnalyticsParameterCurrency: currency as NSObject ,
                           AnalyticsParameterItemName: description as NSObject ,
                           AnalyticsParameterItemID: identifier as NSObject]

        Analytics.logEvent(allName, parameters: fireBaseDic)
        Analytics.logEvent(singleName, parameters: fireBaseDic)
    }
    
}
