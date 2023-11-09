//
//  InAppReceipt.swift
//  
//
//  Created by BJIT on 9/11/23.
//

import Foundation
// MARK: - ReceiptInfo Struct

/// A structure representing information extracted from an in-app receipt.
public struct InAppReceiptInfo {
    // Hardcoded values for testing
    public fileprivate(set) var bundleIdentifier: String? = "com.example.app"
    public fileprivate(set) var bundleIdentifierData: Data? = Data([0x01, 0x02, 0x03])
    public fileprivate(set) var bundleVersion: String? = "1.0"
    public fileprivate(set) var originalApplicationVersion: String? = "1.0"
    public fileprivate(set) var opaqueValue: Data? = Data([0xAA, 0xBB, 0xCC])
    public fileprivate(set) var sha1: Data? = Data([0xDD, 0xEE, 0xFF])
    public fileprivate(set) var receiptCreationDate: Date? = Date()
    public fileprivate(set) var receiptCreationDateString: String?
    public fileprivate(set) var receiptExpirationDate: Date? = Date().addingTimeInterval(30 * 24 * 60 * 60)  // 30 days later
    public fileprivate(set) var receiptExpirationDateString: String?
    // ... (set other ReceiptInfo properties)
}

// MARK: - InAppReceipt Class

/// A class representing an in-app receipt with methods to access its payload properties.
public class InAppReceipt {
    // ReceiptInfo instance to hold hardcoded values
    var receiptInfo = InAppReceiptInfo()

    /// A property representing the payload extracted from the in-app receipt.
    public var payload: InAppReceiptPayload {
        return InAppReceiptPayload(
            bundleIdentifier: receiptInfo.bundleIdentifier ?? "",
            appVersion: receiptInfo.bundleVersion ?? "",
            originalAppVersion: receiptInfo.originalApplicationVersion ?? "",
            expirationDate: receiptInfo.receiptExpirationDate,
            bundleIdentifierData: receiptInfo.bundleIdentifierData ?? Data(),
            opaqueValue: receiptInfo.opaqueValue ?? Data(),
            receiptHash: receiptInfo.sha1 ?? Data(),
            creationDate: receiptInfo.receiptCreationDate ?? Date(),
            ageRating: "",
            environment: "",
            rawData: Data() // Replace with actual raw data if needed
        )
    }
    /// Initializes an InAppReceipt instance with hardcoded ReceiptInfo values.
    public init() {}
}

// MARK: - InAppReceipt Extension

public extension InAppReceipt {
    /// The app’s bundle identifier

    /// Property representing the app's bundle identifier extracted from the in-app receipt payload.
    var bundleIdentifier: String {
        return payload.bundleIdentifier
    }

    /// The app’s version number

    /// Property representing the app's version number extracted from the in-app receipt payload.
    var appVersion: String {
        return payload.appVersion
    }

    /// The version of the app that was originally purchased.

    /// Property representing the original app version extracted from the in-app receipt payload.
    var originalAppVersion: String {
        return payload.originalAppVersion
    }
}
