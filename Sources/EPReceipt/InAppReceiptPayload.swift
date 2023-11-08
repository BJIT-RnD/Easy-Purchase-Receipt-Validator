//
//  InAppReceiptPayload.swift
//  
//
//  Created by BJIT on 8/11/23.
//

import Foundation

// MARK: - InAppReceiptPayload

struct InAppReceiptPayload {
    // MARK: Properties

    /// In-app purchase receipts associated with the payload.
    let purchases: [InAppPurchaseInfo]

    /// The bundle identifier of the app.
    let bundleIdentifier: String

    /// The version number of the app.
    let appVersion: String

    /// The version of the app that was originally purchased.
    let originalAppVersion: String

    /// The date when the app receipt expires.
    let expirationDate: Date?

    /// The bundle identifier data used for validation.
    let bundleIdentifierData: Data

    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
    let opaqueValue: Data

    /// A SHA-1 hash used to validate the receipt.
    let receiptHash: Data

    /// The date when the app receipt was created.
    let creationDate: Date

    /// The age rating of the app.
    let ageRating: String

    /// The environment in which the receipt was generated.
    let environment: String

    /// Raw payload data.
    let rawData: Data

    // MARK: Initialization

    /// Initializes an `InAppReceiptPayload` with the specified values.
    ///
    /// - Parameters:
    ///   - bundleIdentifier: The bundle identifier of the app.
    ///   - appVersion: The version number of the app.
    ///   - originalAppVersion: The version of the app that was originally purchased.
    ///   - purchases: In-app purchase receipts associated with the payload.
    ///   - expirationDate: The date when the app receipt expires.
    ///   - bundleIdentifierData: The bundle identifier data used for validation.
    ///   - opaqueValue: An opaque value used for SHA-1 hash computation during validation.
    ///   - receiptHash: The SHA-1 hash used to validate the receipt.
    ///   - creationDate: The date when the app receipt was created.
    ///   - ageRating: The age rating of the app.
    ///   - environment: The environment in which the receipt was generated.
    ///   - rawData: Raw payload data.
    ///
    init(bundleIdentifier: String, appVersion: String, originalAppVersion: String, purchases: [InAppPurchaseInfo], expirationDate: Date?, bundleIdentifierData: Data, opaqueValue: Data, receiptHash: Data, creationDate: Date, ageRating: String, environment: String, rawData: Data) {
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.originalAppVersion = originalAppVersion
        self.purchases = purchases
        self.expirationDate = expirationDate
        self.bundleIdentifierData = bundleIdentifierData
        self.opaqueValue = opaqueValue
        self.receiptHash = receiptHash
        self.creationDate = creationDate
        self.ageRating = ageRating
        self.environment = environment
        self.rawData = rawData
    }

    // MARK: Checkers

    func isBundleIdentifierValid() -> Bool {
        // Add your validation logic here
        return !bundleIdentifier.isEmpty
    }

    func isAppVersionValid() -> Bool {
        // Add your validation logic here
        return !appVersion.isEmpty
    }

    func isOriginalAppVersionValid() -> Bool {
        // Add your validation logic here
        return !originalAppVersion.isEmpty
    }
}
