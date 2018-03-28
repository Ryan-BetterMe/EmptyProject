//
//  BasicData.swift
//  EmptyProject
//
//  Created by 向辉 on 2018/3/27.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//
//
//  直接将这些基本的信息存储在UserDefaults中

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    
    // 是否已通过审核
    static let reviewPassed = DefaultsKey<Bool>("reviewPassed")
    
    // 是否VIP
    static let isVIP = DefaultsKey<Bool>("isVIP")
    
    // 订阅过期时间
    static let subscriptionExprireDate = DefaultsKey<TimeInterval>("subscriptionExprireDate")
    
    // 周订阅价格
    static let oneWeekSubscriptionPrice = DefaultsKey<String>("oneWeekSubscriptionPrice")
    
    //剩余免费下载次数，默认为3次
    static let restCountForDownload = DefaultsKey<String>("restCountForDownload")
}


