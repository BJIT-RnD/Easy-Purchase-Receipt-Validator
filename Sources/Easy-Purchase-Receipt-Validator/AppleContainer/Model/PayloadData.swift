/**
 File Name: `PayloadData.swift`

 Description: This file defines the `PayloadData` struct, which represents data extracted from an Apple Receipt. It includes information such as bundle identifier, version, opaque value, SHA-1 hash, creation date, expiration date, and in-app purchase details.
 
 - Note: This struct is designed to hold information extracted from an Apple Receipt during processing.
 */

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
    public var inAppPurchasesReceipt: [PurchaseData]?
}
