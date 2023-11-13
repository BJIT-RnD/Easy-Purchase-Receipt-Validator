//
//  InAppReceiptValidator.swift
//
//
//  Created by BJIT on 9/11/23.
//

import Foundation
// MARK: - InAppReceiptValidator Class

/// A class representing an in-app receipt with methods to access its payload properties.
public class InAppReceiptValidator {
    // ReceiptInfo instance to hold hardcoded values
    var receiptInfo : PayloadData

    /// A property representing the payload extracted from the in-app receipt.
    public var processedFinalPayload: InAppReceiptValidatorPayload {
        return InAppReceiptValidatorPayload(
            bundleIdentifier: receiptInfo.bundleIdentifier ?? "",
            appVersion: receiptInfo.bundleVersion ?? "",
            originalAppVersion: receiptInfo.originalApplicationVersion ?? "",
            expirationDate: receiptInfo.receiptExpirationDate,
            bundleIdentifierData: receiptInfo.bundleIdentifierData ?? Data(),
            opaqueValue: receiptInfo.opaqueValue ?? Data(),
            receiptHash: receiptInfo.sha1Hash ?? Data(),
            creationDate: receiptInfo.receiptCreationDate ?? Date(),
            ageRating: "",
            environment: "",
            rawData: Data() // Replace with actual raw data if needed
        )
    }
    /// Initializes an InAppReceipt instance with hardcoded ReceiptInfo values.
    public init(_ receiptInfo: PayloadData) {
        self.receiptInfo = receiptInfo
    }
}

// MARK: - InAppReceiptValidator Extension

public extension InAppReceiptValidator {
    /// The app’s bundle identifier

    /// Property representing the app's bundle identifier extracted from the in-app receipt payload.
    var bundleIdentifier: String {
        return processedFinalPayload.bundleIdentifier
    }

    /// The app’s version number

    /// Property representing the app's version number extracted from the in-app receipt payload.
    var appVersion: String {
        return processedFinalPayload.appVersion
    }

    /// The version of the app that was originally purchased.

    /// Property representing the original app version extracted from the in-app receipt payload.
    var originalAppVersion: String {
        return processedFinalPayload.originalAppVersion
    }
}

// MARK: - IInAppReceiptValidator Extension

/// An extension on InAppReceipt to facilitate receipt validation.
public extension InAppReceiptValidator {

    /// Determine whether the receipt is valid or not.
    ///
    /// - Returns: `true` if the receipt is valid, otherwise `false`.
    var isValidReceipt: Bool {
        do {
            try validateReceipt()
            return true
        } catch {
            return false
        }
    }

    /// Validate In-App Receipt.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    func validateReceipt() throws {
        try checkBundleIdentifierAndVersion()
    }

    /// Verify In-App Receipt.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    @available(*, deprecated, renamed: "validate")
    func verify() throws {
        try checkBundleIdentifierAndVersion()
    }

    /// Verify that the bundle identifier in the receipt matches a hard-coded constant containing the CFBundleIdentifier value you expect in the Info.plist file.
    /// Verify that the version identifier string in the receipt matches a hard-coded constant containing the CFBundleShortVersionString value (for macOS) or the CFBundleVersion value (for iOS) that you expect in the Info.plist file.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    func checkBundleIdentifierAndVersion() throws {
        try checkBundleIdentifier()
    }

    /// Verify that the bundle identifier in the receipt matches a hard-coded constant containing the CFBundleIdentifier value you expect in the Info.plist file.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    func checkBundleIdentifier() throws {
        guard let bundleID = Bundle.main.bundleIdentifier, bundleID == bundleIdentifier else {
            throw ValidationError.validationFailed(reason: .bundleIdentifierVerification)
        }
    }

    /// Verify that the version identifier string in the receipt matches a hard-coded constant containing the CFBundleShortVersionString value (for macOS) or the CFBundleVersion value (for iOS) that you expect in the Info.plist file.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    func checkBundleVersion() throws {
        guard let version = Bundle.main.appVersion, version == appVersion else {
            throw ValidationError.validationFailed(reason: .bundleVersionVerification)
        }
    }
}
