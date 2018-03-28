//
//  String+Extension.swift
//  FotoableKit
//
//  Created by fanshubin on 2018/1/15.
//  Copyright © 2018年 fotoable. All rights reserved.
//

import UIKit

public extension String {

    /// 根据指定字体和宽度得到string的size
    ///
    /// - Parameter font: 指定大小
    /// - Parameter constrainedWidth: 限定宽度
    /// - Parameter lineBreakMode: 换行mode
    /// - Parameter lineSpacing: 行间距
    /// - Returns: string的size
    func sizeWith(font: UIFont, constrainedWidth: CGFloat, textAlignment:
        NSTextAlignment = NSTextAlignment.left, lineBreakMode: NSLineBreakMode = NSLineBreakMode.byWordWrapping, lineSpacing: CGFloat = 0.0) -> CGSize {

        let constrainedRect = CGSize(width: constrainedWidth, height: CGFloat.greatestFiniteMagnitude)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.lineSpacing = lineSpacing

        let boundingBox = self.boundingRect(with: constrainedRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: paragraphStyle], context: nil)
        return boundingBox.size
    }

    /// 根据指定参数得到富文本
    ///
    /// - Parameters:
    ///   - characterSpacing: 字符间距
    ///   - lineSpacing: 行间距
    ///   - textAlignment: 对齐方式
    ///   - lineBreakMode: 换行mode
    /// - Returns: 富文本
    func attributeStringWith(characterSpacing: CGFloat, lineSpacing: CGFloat = 0.0, textAlignment:
        NSTextAlignment = NSTextAlignment.left, lineBreakMode: NSLineBreakMode = NSLineBreakMode.byWordWrapping) -> NSAttributedString {

        let attributedString = NSMutableAttributedString(string: self, attributes: [NSAttributedStringKey.kern: characterSpacing])

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.lineSpacing = lineSpacing
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: self.count))

        return attributedString
    }

}
