//
//  File.swift
//  
//
//  Created by BJIT on 10/11/23.
//

import Foundation
public struct PayloadData {
    /// The bundle identifier of the application as specified in the Info.plist file.
    public var bundleIdentifier: String?

    /// The binary representation of the bundle identifier in Info.plist, used in conjunction with other data to compute the SHA-1 hash during validation.
    public var bundleIdentifierData: Data?

    /// The version of the application as specified in the Info.plist file. In iOS, it corresponds to CFBundleVersion, and in macOS, it corresponds to CFBundleShortVersionString.
    public var bundleVersion: String?

    /// The original version of the application as specified in the Info.plist file. This is typically the same as the 'bundleVersion'.
    public var originalApplicationVersion: String?

    /// An opaque value used in conjunction with other data to compute the SHA-1 hash during validation. This value is typically part of the validation process.
    public var opaqueValue: Data?

    /// The SHA-1 hash computed from the payload data, used to validate the receipt's integrity and authenticity.
    public var sha1Hash: Data?

    /// The date when the receipt was created. It is a part of the receipt's metadata.
    public var receiptCreationDate: Date?

    /// A string representation of the receipt creation date, which may be useful for human-readable presentation.
    public var receiptCreationDateString: String?

    /// The date when the receipt expires, if applicable. It is a part of the receipt's metadata.
    public var receiptExpirationDate: Date?

    /// A string representation of the receipt expiration date, which may be useful for human-readable presentation.
    public var receiptExpirationDateString: String?
    public var inAppPurchases: [PurchaseData]?
}

public struct PurchaseData {
    public var quantities: UInt64?
    public var productIdentifier: String?
    public var transactionId: String?
    public var originalTransactionId: String?
    public var purchaseDate: Date?
    public var originalPurchaseDate: Date?
    public var expiresDate: Date?
    public var isInIntroOfferPeriod: UInt64?
    public var cancellationDate: Date?
    public var webOrderLineItemId: UInt64?
}
