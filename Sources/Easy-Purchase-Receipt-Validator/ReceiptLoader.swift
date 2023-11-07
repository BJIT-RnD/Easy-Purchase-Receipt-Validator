//
//  ReceiptLoader.swift
//
//

import Foundation

public final class ReceiptLoader {
    /// Loads the receipt from appStoreReceiptURL Bundle
    /// - Parameter url: optional type url for fetching receipt
    /// - Parameter completion: sends back receipt as Data and error if any found .
    ///
    func getReceipt(_ url: URL? = Bundle.main.appStoreReceiptURL, _ completion: @escaping(_ data: Data?, _ error: ReceiptError?) -> Void) {
        guard let appReceiptURL = url else {
            completion(nil, .invalidURL)
            return
        }
        do {
            let receiptData = try Data(contentsOf: appReceiptURL)
            completion(receiptData, nil)
        } catch {
            completion(nil, ReceiptError.errorType(url: appReceiptURL))
        }
    }
}
