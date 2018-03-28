//
//  UINavigationController+Extension.swift
//  FotoableKit
//
//  Created by fanshubin on 2018/1/26.
//  Copyright © 2018年 fotoable. All rights reserved.
//

import UIKit

// MARK:- Stack manage
public extension UINavigationController {

    /// 得到当前navigation controller的root view controller
    ///
    /// - Returns: root view controller
    func rootViewController() -> UIViewController? {
        return viewControllers.first
    }

    /// 在当前navigation controller找到对应类名的view controller
    ///
    /// - Parameter className: 类名
    /// - Returns: 对应的view controller
    func findViewController(className: AnyClass) -> UIViewController? {

        for viewController in viewControllers {
            if viewController.isKind(of: className) {
                return viewController
            }
        }
        return nil
    }

    /// pop到对应类名的view controller
    ///
    /// - Parameters:
    ///   - className: 类名
    ///   - animated: 是否动画
    func popToViewControllerWithClassName(className: AnyClass, animated: Bool) {

        guard let viewController = findViewController(className: className) else { return }
        popToViewController(viewController, animated: animated)
    }

    /// pop到对应的level的view controller
    ///
    /// - Parameters:
    ///   - level: 向上pop的level数
    ///   - animated: 是否动画
    func popToViewControllerWithLevel(level: Int, animated: Bool) {

        let viewControllersCount = viewControllers.count
        if viewControllersCount > level {
            let index = viewControllersCount - level - 1
            let viewController = viewControllers[index]
            popToViewController(viewController, animated: animated)
        } else {
            popToRootViewController(animated: animated)
        }
    }
    
}
