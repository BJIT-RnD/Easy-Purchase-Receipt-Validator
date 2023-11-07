//
//  IAPHelper.swift
//  Demo
//
//  Created by BJIT on 17/10/23.
//

import Foundation
import StoreKit

final class IAPHelper: NSObject {
    static let shared = IAPHelper()
    var availableProducts: [SKProduct] = []
    var invalidProductIdentifiers: [String] = []
    /// Keeps track of all purchases.
    var purchased: [SKPaymentTransaction] = []
    /// Keeps track of all restored purchases.
    var restored: [SKPaymentTransaction] = []
    /// Indicates whether there are restorable purchases.
    var hasRestorablePurchases = false
    var purchasingCount = 0
    var deferredCount = 0
    var purchasedCount = 0
    var failedCount = 0
    var restoredCount = 0
    var removedProductIdentifiers: [String] = []
    var restoreFailedCount = 0
    func fetchProductsData(type products: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(products))
        request.delegate = self
        request.start()
    }
    func buy(_ product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    /// Restores all previously completed purchases.
    func restoreProducts() {
        if !restored.isEmpty {
            restored.removeAll()
        }
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate, SKRequestDelegate
extension IAPHelper: SKProductsRequestDelegate, SKRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            availableProducts = response.products
            FetchProductsListVC.viewModel.fetchedProducts = response.products
        }
        if !response.invalidProductIdentifiers.isEmpty {
            invalidProductIdentifiers = response.invalidProductIdentifiers
        }
    }
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print(error.localizedDescription)
        FetchProductsListVC.viewModel.fetchedProducts = []
    }
}

// MARK: - Payment Queue Delegates
extension IAPHelper: SKPaymentTransactionObserver {
    /// Called when there are transactions in the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                purchasingCount += 1
                print(purchasingCount)
            case .deferred:
                deferredCount += 1
                print(Messages.deferred)
                // The purchase was successful.
            case .purchased:
                purchasedCount += 1
                handlePurchased(transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                // The transaction failed.
            case .failed:
                failedCount += 1
                handleFailed(transaction)
                // There're restored products.
            case .restored:
                restoredCount += 1
                handleRestored(transaction)
            @unknown default:
                fatalError(Messages.unknownPaymentTransaction)
            }
        }
    }
}

// MARK: - Handle Payment Transactions
extension IAPHelper {
    /// Handles successful purchase transactions.
    func handlePurchased(_ transaction: SKPaymentTransaction) {
        purchased.append(transaction)
        print("\(Messages.deliverContent) \(transaction.payment.productIdentifier).")
        // Finish the successful transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    /// Handles failed purchase transactions.
    func handleFailed(_ transaction: SKPaymentTransaction) {
        var message = "\(Messages.purchaseOf) \(transaction.payment.productIdentifier) \(Messages.failed)"
        if let error = transaction.error {
            message += "\n\(Messages.error) \(error.localizedDescription)"
            print("\(Messages.error) \(error.localizedDescription)")
        }
        // Do not send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            print(message)
        }
        // Finish the failed transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    /// Handles restored purchase transactions.
    func handleRestored(_ transaction: SKPaymentTransaction) {
        hasRestorablePurchases = true
        restored.append(transaction)
        print("\(Messages.restoreContent) \(transaction.payment.productIdentifier).")
        print("Restore Successful")
        // Finishes the restored transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
// PaymentQueue Methods
extension IAPHelper {
    /// Logs all transactions that have been removed from the payment queue.
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("\(transaction.payment.productIdentifier) \(Messages.removed)")
            removedProductIdentifiers.append(transaction.payment.productIdentifier)
        }
    }
    
    /// Called when an error occur while restoring purchases. Notify the user about the error.
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreFailedCount += 1
        if let error = error as? SKError, error.code != .paymentCancelled {
            print(error.localizedDescription)
            RestoreVC.viewModel.fetchList.value = restored
        }
    }
    
    /// Called when all restorable transactions have been processed by the payment queue.
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print(Messages.restorable)
        RestoreVC.viewModel.fetchList.value = restored
        if !hasRestorablePurchases {
            print(Messages.noRestorablePurchases)
        }
    }
}
