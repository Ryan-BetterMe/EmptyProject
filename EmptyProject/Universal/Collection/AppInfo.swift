//
//  AppInfo.swift
//  EmptyProject
//
//  Created by 向辉 on 2018/3/27.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//

import Foundation

// MARK: - AppInfo
public struct AppInfo {
    
    /// bundle ID
    static let bundleID = Bundle.main.bundleIdentifier!
    
    /// App显示名
    static let displayName = Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? ""
    
    /// 主版本号
    static let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
    
    /// build编号
    static let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"]!
}
