//
//  InAppReceipt.swift
//  
//
//  Created by BJIT on 8/11/23.
//
import Foundation

/**
 Class representing an in-app receipt.
 */
public class InAppReceipt {
    /// Receipt from PKCS7 container
    internal var receipt: PKCS7InAppReceipt
    /// Payload of the receipt. Payload object contains all meta information.
    internal var payload: InAppReceiptPayload { receipt.payload }

    /**
     Initializes an `InAppReceipt` with the provided receipt data.

     - Parameter receiptData: `Data` object representing the in-app receipt.
     */
    public init(receiptData: Data) {
        self.receipt = try PKCS7InAppReceipt(rawData: receiptData)
    }
}

// MARK: - InAppReceipt Extension

public extension InAppReceipt {
    /// The app’s bundle identifier
    var bundleIdentifier: String {
        return payload.bundleIdentifier
    }

    /// The app’s version number
    var appVersion: String {
        return payload.appVersion
    }

    /// The version of the app that was originally purchased.
    var originalAppVersion: String {
        return payload.originalAppVersion
    }
}
