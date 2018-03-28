//
//  UIImage+Extension.swift
//  FotoableKit
//
//  Created by fanshubin on 2018/1/2.
//  Copyright © 2018年 fotoable. All rights reserved.
//

import UIKit

// MARK:- New image
public extension UIImage {

    /// 从文件加载，不长驻内存，适用于非Assets导入的图
    /// - Parameters:
    ///   - name: 文件名
    ///   - type: 文件扩展名
    convenience init?(named name: String, ofType type: String) {

        var filePath = Bundle.main.path(forResource: name, ofType: type)
        if nil == filePath {
            let name = name + "@\(Int(UIScreen.main.scale))x"

            filePath = Bundle.main.path(forResource: name, ofType: type)
            if nil == filePath {
                return nil
            }
        }

        self.init(contentsOfFile: filePath!)
    }

    /// 由当前图生成一个指定大小的图片
    ///
    /// - Parameter size: 指定大小
    /// - Returns: 生成的图片
    func resizeTo(size: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let toImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return toImage
    }

    /// 按比例缩放图片生成一个新的图
    ///
    /// - Parameter scale: 缩放比例
    /// - Returns: 缩放后的图
    func scaleTo(scale: CGFloat) -> UIImage {

        let toSize = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        return resizeTo(size: toSize)
    }

    /// 将图片平埔生成一个新的图
    ///
    /// - Parameter size: 新图的大小
    /// - Returns: 平埔后生成的图
    func tiledImageTo(size: CGSize) -> UIImage {

        let view = UIView()
        view.bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        view.backgroundColor = UIColor(patternImage: self)

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }

}
