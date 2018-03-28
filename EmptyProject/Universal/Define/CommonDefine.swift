//
//  CommonDefine.swift
//  EmptyProject
//
//  Created by 向辉 on 2018/3/26.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//
//  这是所以项目都需要的常量和拓展的方法，如果是当前项目所独有的，则在CustomDefine文件中拓展

import Foundation
import UIKit
import KeychainAccess

// MARK: - NetworkInfo
public struct NetworkURL {
    
    // 审核的接口
    static let reviewBaseURL = ""
    
    // 请求请求接口
    static let requestBaseURL = ""
}

// MARK: - 内购相关信息
public struct IAPInfomation {
    
    // 订阅商品的secret
    static let subscriptionSecret = ""
    
    // 商品ID
    enum ProductID {
        static let oneWeek = ""
    }
    
    // 商品的价格
    enum ProductPrice {
        
        // 审核默认价格
        static let reviewPrice = "$1.99"
        
        // 过审核价格
        static let normalPrice = "$49.99"
    }
}

// MARK: - 统计相关
public enum AnalysisParameters {
    static let facebookID = "165053104095460"
    static let appleAppID = "1315559798"
}
