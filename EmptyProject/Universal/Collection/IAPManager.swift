//
//  IAPManager.swift
//  EmptyProject
//
//  Created by 向辉 on 2018/3/27.
//  Copyright © 2018年 JaniXiang. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

public typealias PurchaseCompletion = (_ result: IAPPurchaseResult) -> Void
public typealias RestoreCompletion = (_ result: IAPRestoreResult) -> Void
public typealias VerifyCompletion = (_ result: IAPVerifyResult) -> Void

/// purchase结果
public enum IAPPurchaseResult {
    case success(product: SKProduct, expireDate: Date?)
    case canceled
    case purchaseFail
    case verifyFail(product: SKProduct)
}

/// restore结果
public enum IAPRestoreResult {
    case success(expireDate: Date)
    case expired
    case fail
    case nothing
}

/// verify结果
public enum IAPVerifyResult {
    case success(expireDate: Date?)
    case expired
    case notPurchased
    case netError
    case fail
}

public class IAPManager: NSObject {
    
    /// 验证密钥
    public var secret = ""
    
    public static let shareInstance = IAPManager()
    private override init() {}
}

public extension IAPManager  {
    
    /// 结束未完成的购买，每次启动时要在didFinishLaunchingWithOptions里调用
    func completeTransaction() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
            }
        }
    }
    
    /// 根据商品ID得到商品信息
    ///
    /// - Parameters:
    ///   - productIDs: 商品ID
    ///   - completion: 获取完成后的回调
    func retriveProductsInfo(productIDs: Set<String>, completion: @escaping (_ result: RetrieveResults) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(productIDs) { result in
            completion(result)
        }
    }
    
    /// 自动续期订阅
    ///
    /// - Parameters:
    ///   - productID: 商品ID
    ///   - completion: 购买结束后的回调
    func purchaseAutoRenewable(productID: String, completion: @escaping PurchaseCompletion) {
        
        SwiftyStoreKit.purchaseProduct(productID, atomically: true) { [weak self] result in
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                self?.verifyAutoRenewable(productID: productID, completion: { (result) in
                    switch result {
                    case .success(let expireDate):
                        completion(IAPPurchaseResult.success(product: purchase.product, expireDate: expireDate))
                    case .expired:
                        completion(IAPPurchaseResult.purchaseFail)
                    case .notPurchased:
                        completion(IAPPurchaseResult.purchaseFail)
                    default:
                        completion(IAPPurchaseResult.verifyFail(product: purchase.product))
                    }
                })
            } else  {
                if case .error(let error) = result {
                    switch error.code {
                    case .paymentCancelled:
                        completion(IAPPurchaseResult.canceled)
                    default:
                        completion(IAPPurchaseResult.purchaseFail)
                    }
                } else {
                    completion(IAPPurchaseResult.purchaseFail)
                }
            }
        }
    }
    
    /// 购买消耗型产品
    ///
    /// - Parameters:
    ///   - productID: 商品ID
    ///   - verifyFromApple: 是否向苹果服务器验证购买有效性，默认为false，在自己服务器做验证
    ///   - completion: 购买结束后的回调
    func purchaseConsumable(productID: String, verifyFromApple: Bool = false, completion: @escaping PurchaseCompletion) {
        
        SwiftyStoreKit.purchaseProduct(productID, atomically: true) { [weak self] result in
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                if verifyFromApple {
                    self?.verifyConsumable(productID: productID, completion: { (result) in
                        switch result {
                        case .success:
                            completion(IAPPurchaseResult.success(product: purchase.product, expireDate: nil))
                        case .expired:
                            completion(IAPPurchaseResult.purchaseFail)
                        case .notPurchased:
                            completion(IAPPurchaseResult.purchaseFail)
                        default:
                            completion(IAPPurchaseResult.verifyFail(product: purchase.product))
                        }
                    })
                } else {
                    completion(IAPPurchaseResult.success(product: purchase.product, expireDate: nil))
                }
            } else  {
                if case .error(let error) = result {
                    switch error.code {
                    case .paymentCancelled:
                        completion(IAPPurchaseResult.canceled)
                    default:
                        completion(IAPPurchaseResult.purchaseFail)
                    }
                } else {
                    completion(IAPPurchaseResult.purchaseFail)
                }
            }
        }
    }
    
    /// 恢复自动续期订阅
    ///
    /// - Parameters:
    ///   - productID: 商品ID
    ///   - completion: 恢复结束后的回调
    func restore(productID: String, completion: @escaping RestoreCompletion) {
        SwiftyStoreKit.restorePurchases(atomically: true) { [weak self] results in
            if results.restoreFailedPurchases.count > 0 {
                completion(IAPRestoreResult.fail)
            } else if results.restoredPurchases.count > 0 {
                
                self?.verifyAutoRenewable(productID: productID, completion: { (result) in
                    switch result {
                    case .success(let expireDate):
                        completion(IAPRestoreResult.success(expireDate: expireDate!))
                    case .expired:
                        completion(IAPRestoreResult.expired)
                    default:
                        completion(IAPRestoreResult.fail)
                    }
                })
            } else {
                completion(IAPRestoreResult.nothing)
            }
        }
    }
    
    /// 验证自动续期订阅票据
    ///
    /// - Parameters:
    ///   - productID: 商品ID
    ///   - completion: 验证结束后的回调
    func verifyAutoRenewable(productID: String, completion: @escaping VerifyCompletion) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.secret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productID,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expireDate, _):
                    completion(IAPVerifyResult.success(expireDate: expireDate))
                case .expired(_, _):
                    completion(IAPVerifyResult.expired)
                case .notPurchased:
                    completion(IAPVerifyResult.notPurchased)
                }
            case .error(let error):
                
                switch error {
                case .networkError(_):
                    completion(IAPVerifyResult.netError)
                default:
                    completion(IAPVerifyResult.fail)
                }
            }
        }
    }
    
    /// 验证消耗型产品票据
    ///
    /// - Parameters:
    ///   - productID: 商品ID
    ///   - completion: 验证结束后的回调
    func verifyConsumable(productID: String, completion: @escaping VerifyCompletion) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: self.secret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: productID, inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased:
                    completion(IAPVerifyResult.success(expireDate: nil))
                case .notPurchased:
                    completion(IAPVerifyResult.notPurchased)
                }
            case .error(let error):
                
                switch error {
                case .networkError(_):
                    completion(IAPVerifyResult.netError)
                default:
                    completion(IAPVerifyResult.fail)
                }
            }
        }
    }
    
}
