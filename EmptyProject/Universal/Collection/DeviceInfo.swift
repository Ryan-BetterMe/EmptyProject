//
//  DeviceInfo.swift
//  EmptyProject
//
//  Created by 向辉 on 2018/3/27.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//

import UIKit
import KeychainAccess

// MARK: - Common Const
public struct DeviceInfo {
    
    /// 屏幕宽度
    public static let screenWidth = UIScreen.main.bounds.width
    
    /// 屏幕高度
    public static let screenHeight = UIScreen.main.bounds.height
    
    /// 当前scale
    public static let scale = UIScreen.main.scale
    
    /// 状态栏高度
    public static let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    /// 导航栏高度
    public static let navigationBarHeight = UIApplication.shared.statusBarFrame.height + 44.0
    
    /// tabbar高度
    public static let tabbarHeight: CGFloat = 49.0
    
    /// 是否3.5寸屏
    public static let isInch35 = (320 == screenWidth && 480 == screenHeight)
    
    /// 是否4.0寸屏
    public static let isInch40 = (320 == screenWidth && 568 == screenHeight)
    
    /// 是否4.7寸屏
    public static let isInch47 = (375 == screenWidth && 667 == screenHeight)
    
    /// 是否5.5寸屏
    public static let isInch55 = (414 == screenWidth && 736 == screenHeight)
    
    /// 是否5.8寸屏
    public static let isInch58 = (375 == screenWidth && 812 == screenHeight)
    
    /// 是否iPhone
    public static let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    
    /// 是否iPad
    public static let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    /// 是否iPhoneX
    public static let isIphoneX = isInch58
    
    /// 是否iPhone5s或更小的设备
    public static let isIphone5sOrEarlier = 568 >= screenHeight
    
    /// UDID
    public static var udid: String {
        let keychain = Keychain(service: AppInfo.bundleID)
        if let savedUDID = keychain["udid"] {
            return savedUDID
        } else {
            let newUDID = UUID().uuidString
            keychain["udid"] = newUDID
            return newUDID
        }
    }
    
    /// 设备型号
    public static let model = UIDevice.current.model
    
    // 设备具体型号
    public static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
            
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3":                              return "iPhoneX"
            
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,7", "iPad6,8":                      return "iPad Pro"
            
        case "AppleTV5,3":                              return "Apple TV"
            
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
            
        }
    }
    
    /// 系统版本号
    public static let systemVersion = UIDevice.current.systemVersion
    
    /// 当前语言
    public static let currentLanguage = NSLocale.preferredLanguages[0]
    
    /// 当前语言编码
    public static let currentLanguageCode = NSLocale.current.languageCode!
    
    /// 当前设置的区域编码
    public static let currentRegionCode = NSLocale.current.regionCode!
    
}
