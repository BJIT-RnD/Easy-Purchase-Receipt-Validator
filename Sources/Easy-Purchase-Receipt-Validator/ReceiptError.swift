//
//  ErrorHandler.swift
//

import Foundation

public enum ReceiptError: Error {
    case fileNotFound
    case invalidData
    case invalidURL
    case verificationFailed
    case invalidReceiptBlock
    case notAutoRenewableProduct
    case productIsCancelled
    case productNotPurchased
    /// Dectects Error
    /// - Parameter url: receipt loading url
    ///
    static func errorType(url: URL) -> ReceiptError {
        if url.path.isEmpty {
            return .invalidURL
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            return .fileNotFound
        } else {
            return .invalidData
        }
    }
}
