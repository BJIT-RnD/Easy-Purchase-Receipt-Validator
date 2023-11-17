//
//  InAppReceiptValidator.swift
///
/// Description: A class representing an in-app receipt with methods to access its payload properties.
///  Created by BJIT on 9/11/23.
//

import Foundation
import CommonCrypto
#if canImport(UIKit)
import UIKit
#endif

// MARK: - InAppReceiptValidatorProtocol
/// Protocol defining the contract for in-app receipt validation.
///
/// Conforming classes should implement methods and properties to access and validate in-app receipt information.
protocol InAppReceiptValidatorProtocol {
    var bundleIdentifier: String? { get }
    var originalAppVersion: String? { get }
    var bundleVersion: String? { get }
    var bundleIdentifierData: Data? { get }
    var opaqueValue: Data? { get }
    var receiptHash: Data? { get }
    var creationDate: Date? { get }
    var expirationDate: Date? { get }
    var creationDateString: String? { get }
    var expirationDateString: String? { get }
    var isValidReceipt: Bool { get }
    func checkExpirationDateValid() -> Bool
}

// MARK: - InAppReceiptValidator Class

public class InAppReceiptValidator: InAppReceiptValidatorProtocol {
    // ReceiptInfo instance to hold hardcoded values
    private var processedFinalPayload : PayloadData

    /// Initializes an InAppReceipt instance with hardcoded ReceiptInfo values.
    public init(_ receiptInfo: PayloadData) {
        self.processedFinalPayload = receiptInfo
    }
}

// MARK: - InAppReceiptValidator Extension

public extension InAppReceiptValidator {
    /// The app’s bundle identifier

    /// Property representing the app's bundle identifier extracted from the in-app receipt payload.
    var bundleIdentifier: String? {
        return processedFinalPayload.bundleIdentifier
    }

    /// The app’s version number
    var originalAppVersion: String? {
        return processedFinalPayload.originalApplicationVersion
    }

    /// Property representing the app's version number extracted from the in-app receipt payload.
    var bundleVersion: String? {
        return processedFinalPayload.bundleVersion
    }

    /// Used to validate the receipt
    var bundleIdentifierData: Data? {
        return processedFinalPayload.bundleIdentifierData //?? Data()
    }

    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
    var opaqueValue: Data? {
        return processedFinalPayload.opaqueValue //?? Data()
    }

    /// A SHA-1 hash, used to validate the receipt.
    var receiptHash: Data? {
        return processedFinalPayload.sha1Hash
    }

    /// Creation date of the receipt
    var creationDate: Date? {
        return processedFinalPayload.receiptCreationDate
    }

    /// Expiration date of the receipt
    var expirationDate: Date? {
        return processedFinalPayload.receiptExpirationDate
    }
    
    /// Creation date of the receipt in String
    var creationDateString: String? {
        return processedFinalPayload.receiptCreationDateString
    }

    /// Expiration date of the receipt in String
    var expirationDateString: String? {
        return processedFinalPayload.receiptExpirationDateString
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
    private func validateReceipt() throws {
        try verifyHash()
        try checkBundleIdentifierAndVersion()
    }

    /// Verify that the bundle identifier in the receipt matches a hard-coded constant containing the CFBundleIdentifier value you expect in the Info.plist file.
    /// Verify that the version identifier string in the receipt matches a hard-coded constant containing the CFBundleShortVersionString value (for macOS) or the CFBundleVersion value (for iOS) that you expect in the Info.plist file.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    private func checkBundleIdentifierAndVersion() throws {
        try checkBundleIdentifier()
        try checkBundleVersion()
    }

    /// Verify that the bundle identifier in the receipt matches a hard-coded constant containing the CFBundleIdentifier value you expect in the Info.plist file.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    private func checkBundleIdentifier() throws {
        guard let bundleID = Bundle.main.bundleIdentifier, bundleID == bundleIdentifier else {
            throw ValidationError.validationFailed(reason: .bundleIdentifierVerification)
        }
    }

    /// Verify that the version identifier string in the receipt matches a hard-coded constant containing the CFBundleShortVersionString value (for macOS) or the CFBundleVersion value (for iOS) that you expect in the Info.plist file.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    private func checkBundleVersion() throws {
        guard let version = Bundle.main.bundleVersion, version == bundleVersion else {
            throw ValidationError.validationFailed(reason: .bundleVersionVerification)
        }
    }

    /// Checks the validity of the expiration date in comparison to the current date.
    ///
    /// This function compares the expiration date extracted from the processed final payload
    /// with the current date to determine if the receipt is still valid or has expired.
    ///
    /// - Returns: `true` if the expiration date is greater than or equal to the current date,
    /// indicating that the receipt is still valid. Returns `false` if the expiration date is earlier
    /// than the current date, indicating that the receipt has expired.
    func checkExpirationDateValid() -> Bool {
        let currentDate = Date()

        guard let expirationDate = processedFinalPayload.receiptExpirationDate else { return false }

        return expirationDate >= currentDate
    }

    /// Verify the hash of the computed data against the stored receipt hash.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    private func verifyHash() throws {
        if (computedHash != receiptHash) {
            throw ValidationError.validationFailed(reason: .hashValidation)
        }
    }

    /// Compute SHA-1 hash for the provided data.
    ///
    /// - returns: SHA-1 hash as Data.
    private var computedHash: Data {
        let uuidData = guid()
        if let opaqueData = opaqueValue, let bundleIdData = bundleIdentifierData {
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            var ctx = CC_SHA1_CTX()
            _ = uuidData.withUnsafeBytes { uuidBytes in
                CC_SHA1_Init(&ctx)
                CC_SHA1_Update(&ctx, uuidBytes.baseAddress, CC_LONG(uuidData.count))
            }
            _ = opaqueData.withUnsafeBytes { opaqueBytes in
                CC_SHA1_Update(&ctx, opaqueBytes.baseAddress, CC_LONG(opaqueData.count))
            }
            _ = bundleIdData.withUnsafeBytes { bundleIdBytes in
                CC_SHA1_Update(&ctx, bundleIdBytes.baseAddress, CC_LONG(bundleIdData.count))
            }
            CC_SHA1_Final(&hash, &ctx)

            return Data(hash)
        }
        return Data()
    }

    /// Generate a unique identifier for the current platform.
    ///
    /// - returns: A Data object containing the unique identifier.
    private func guid() -> Data {
        #if os(watchOS)
        var uuidBytes = WKInterfaceDevice.current().identifierForVendor!.uuid
        return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
        #elseif !targetEnvironment(macCatalyst) && (os(iOS) || os(tvOS))
        var uuidBytes = UIDevice.current.identifierForVendor!.uuid
        return Data(bytes: &uuidBytes, count: MemoryLayout.size(ofValue: uuidBytes))
        #elseif targetEnvironment(macCatalyst) || os(macOS)
        return Data()
        #endif
    }
}
