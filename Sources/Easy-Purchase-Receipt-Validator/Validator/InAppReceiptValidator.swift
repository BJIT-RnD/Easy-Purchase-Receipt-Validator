//
//  InAppReceiptValidator.swift
///
/// Description: A class representing an in-app receipt with methods to access its payload properties.
///  Created by BJIT on 9/11/23.
//

import Foundation
import CommonCrypto
import Security
#if canImport(UIKit)
import UIKit
#endif

// MARK: - InAppReceiptValidatorProtocol
/// Protocol defining the contract for in-app receipt validation.
///
/// Conforming classes should implement methods and properties to access and validate in-app receipt information.
public protocol InAppReceiptValidatorProtocol {
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
    var purchases: [PurchaseData]? { get }
    func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String?
    func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool
    func getPurchaseExpiredDatebyProductId(ofProductIdentifier productIdentifier: String) throws -> Date?
    func allPurchasesByProductId(ofProductIdentifier productIdentifier: String,
                   sortedBy sort: ((PurchaseData, PurchaseData) -> Bool)?) -> [PurchaseData]
    func isActiveAutoRenewableByDate(ofProductIdentifier productIdentifier: String, forDate date: Date) throws -> PurchaseData?
    func isCurrentlyActiveAutoRenewable(ofProductIdentifier productIdentifier: String) throws -> PurchaseData?
    var allAutoRenewables: [PurchaseData] { get }
    func activeAutoRenewables() throws -> [PurchaseData]
    func isValidReceipt() throws -> Bool
    func isNonRenewableActive(productIdentifier: String, validForDay day: Int, currentDate: Date) throws -> Bool
    func isNonRenewableActive(productIdentifier: String, validForMonth month: Int, currentDate: Date) throws -> Bool
    func isNonRenewableActive(productIdentifier: String, validForYear year: Int, currentDate: Date) throws -> Bool
}

// MARK: - InAppReceiptValidator Class
public final class InAppReceiptValidator: InAppReceiptValidatorProtocol {
    // ReceiptInfo instance to hold hardcoded values
    private let processedFinalPayload : PayloadData
    private let signatures : [SignatureInfo]
    private let iTunesPublicKey: Data
    let receiptBlock: Data

    /// Initializes an InAppReceipt instance with hardcoded ReceiptInfo values.
    public init(withPayLoad: PayloadData, signatures: [SignatureInfo], andReceipt: Data, iTunesPublicKey: Data) {
        self.processedFinalPayload = withPayLoad
        self.signatures = signatures
        self.receiptBlock = andReceipt
        self.iTunesPublicKey = iTunesPublicKey
    }
}

// MARK: - InAppReceiptValidator Extension : Providing the access for basic components of the given receipt

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
        return processedFinalPayload.bundleIdentifierData
    }

    /// An opaque value used, with other data, to compute the SHA-1 hash during validation.
    var opaqueValue: Data? {
        return processedFinalPayload.opaqueValue
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

    /// In-app purchase's receipts
    var purchases: [PurchaseData]? {
        return processedFinalPayload.inAppPurchasesReceipt
    }
}

// MARK: - InAppReceiptValidator Extension: Providing the validation of the given receipt.

/// An extension on InAppReceipt to facilitate receipt validation.
public extension InAppReceiptValidator {
    /// Determine whether the receipt is valid or not.
    ///
    /// - Returns: `true` if the receipt is valid, otherwise `false`.
    func isValidReceipt() throws -> Bool {
        try validateReceipt()
        return true
    }

    /// Validate In-App Receipt.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    private func validateReceipt() throws {
        try verifyHash()
        try checkBundleIdentifierAndVersion()
        _ = try assambleAndverifySignature()
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

    /// Verify the hash of the computed data against the stored receipt hash.
    ///
    /// - throws: An error in the InAppReceipt domain if verification fails.
    private func verifyHash() throws {
        if computedHash != receiptHash {
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

extension InAppReceiptValidator{
    private func getSecterPublicKey(from iTunesPublicKeyContainer: Data) throws -> SecKey {
        let keyDict: [String:Any] =
        [
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
        ]
        guard let iTunesPublicKeySec = SecKeyCreateWithData(iTunesPublicKeyContainer as CFData, keyDict as CFDictionary, nil) else {
            throw ValidationError.validationFailed(reason: .signatureValidation(.unableToLoadAppleIncPublicSecKey))
        }
        return iTunesPublicKeySec
    }
    private func assambleAndverifySignature() throws -> Bool {
        let appleRootCertificatePublicKey = try getSecterPublicKey(from: iTunesPublicKey)
        guard let firstSignature = signatures.first,
              let signatureRawData = firstSignature.signatureData else {
            throw ValidationError.validationFailed(reason: .signatureValidation(.receiptSignedDataNotFound))
        }
        return try verifySignature(signature: signatureRawData, withPublicKey: appleRootCertificatePublicKey, forData: receiptBlock)
    }
    
    private func verifySignature(signature: Data, withPublicKey publicKey: SecKey, forData data: Data) throws -> Bool {
        let algorithm: SecKeyAlgorithm = .rsaSignatureMessagePKCS1v15SHA1
        var error: Unmanaged<CFError>?
        let result = SecKeyVerifySignature(publicKey, algorithm, data as CFData, signature as CFData, &error)
        if !result {
            if let err = error?.takeRetainedValue(){
                print(err)
                throw ValidationError.validationFailed(reason: .signatureValidation(.invalidSignature))
            }
        }
        return result
    }
}
// MARK: - InAppReceiptValidator Extension: Parsing different purchases data for different products of the given receipt
extension InAppReceiptValidator {
    // MARK: Original Transaction Identifier

    /// Returns the original transaction identifier for the first purchase of a specific product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier.
    /// - Returns: The original transaction identifier, or `nil` if no purchases exist.
    public func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String? {
        return allPurchasesByProductId(ofProductIdentifier: productIdentifier).first?.originalTransactionId
    }

    // MARK: Contains Purchase

    /// Checks if there is a purchase for a specific product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier.
    /// - Returns: `true` if the product has been purchased, `false` otherwise.
    public func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool {
        guard let unwrappedPurchases = purchases else {
            return false
        }

        for item in unwrappedPurchases {
            if item.productIdentifier == productIdentifier {
                return true
            }
        }

        return false
    }

    // MARK: Purchase Expired Date

    /// Returns the expiration date of the first purchase for a specific product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier.
    /// - Returns: The expiration date, or `nil` if no purchases exist or the expiration date is `nil`.
    public func getPurchaseExpiredDatebyProductId(ofProductIdentifier productIdentifier: String) throws -> Date? {
        guard let purchased = allPurchasesByProductId(ofProductIdentifier: productIdentifier).first,
              let expirationDate = purchased.expiresDate else {
            throw PurchaseDataError.expireDateNotAvailable
        }
        return expirationDate
    }

    // MARK: Purchases

    /// Returns an array of purchases for a specific product identifier.
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier.
    ///   - sort: An optional sorting block for the purchases.
    /// - Returns: An array of purchases, sorted if a sorting block is provided.
    public func allPurchasesByProductId(ofProductIdentifier productIdentifier: String,
                   sortedBy sort: ((PurchaseData, PurchaseData) -> Bool)? = nil) -> [PurchaseData] {
        guard let unwrappedPurchases = purchases else {
            return []
        }

        let filtered: [PurchaseData] = unwrappedPurchases.filter {
            $0.productIdentifier == productIdentifier
        }

        if let sort = sort {
            return filtered.sorted(by: sort)
        } else {
            return filtered.sorted(by: {
                guard let date1 = $0.purchaseDate, let date2 = $1.purchaseDate else {
                    return true
                }
                return date1 > date2
            })
        }
    }

    // MARK: Currently Active Auto-Renewable Subscription Purchases Within a Specific Date

    /// Returns the currently active auto-renewable subscription purchase for a specific product identifier and date.
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier.
    ///   - date: The date for which the subscription's status is checked.
    /// - Returns: The active auto-renewable subscription purchase, or `nil` if none is found.
    ///
    public func isActiveAutoRenewableByDate(ofProductIdentifier productIdentifier: String, forDate date: Date) throws -> PurchaseData? {
        let filteredbyProductId = allPurchasesByProductId(ofProductIdentifier: productIdentifier)

        for purchase in filteredbyProductId {
            if try purchase.isActiveAutoRenewable(forDate: date) {
                return purchase
            }
        }
        return nil
    }

    // MARK: Currently Active Auto-Renewable Subscription Purchases

    /// Returns the currently active auto-renewable subscription purchase for a specific product identifier.
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier.
    /// - Returns: The active auto-renewable subscription purchase by checking current date using Date(), or `nil` if none is found.
    ///
    public func isCurrentlyActiveAutoRenewable(ofProductIdentifier productIdentifier: String) throws -> PurchaseData? {
        let filteredbyProductId = allPurchasesByProductId(ofProductIdentifier: productIdentifier)
        let date = Date()
        for purchase in filteredbyProductId {
            if try purchase.isActiveAutoRenewable(forDate: date) {
                return purchase
            }
        }
        return nil
    }
    
    // MARK: All Auto-renewable products receipt containing

    /// Returns all the auto-renewable subscription purchase ever done by the user.
    ///
    /// - Returns: The list of all the auto-renewable subscription purchase ever done by the user.
    ///
    public var allAutoRenewables: [PurchaseData] {
        var activeAutoRenews: [PurchaseData] = []
        guard let purchases = purchases else {
            return activeAutoRenews
        }
        for purchase in purchases {
            if purchase.isAutoRenewProduct {
                activeAutoRenews.append(purchase)
            }
        }
        return activeAutoRenews
    }
    
    // MARK: All Active Auto-renewable products receipt containing

    /// Returns all the active auto-renewable subscription purchases.
    ///
    /// - Returns: The list of all the active auto-renewable subscription purchase ever done by the user.
    ///
    public func activeAutoRenewables() throws -> [PurchaseData] {
        var activeAutoRenews: [PurchaseData] = []
        guard let purchases = purchases else {
            return activeAutoRenews
        }
        for purchase in purchases {
            if try (purchase.isAutoRenewProduct && purchase.isActiveAutoRenewable()) {
                activeAutoRenews.append(purchase)
            }
        }
        return activeAutoRenews
    }
    
    public func isNonRenewableActive(productIdentifier: String, validForDay day: Int, currentDate: Date) throws -> Bool {
        let activeDays = day
        let status = try checkNonRenewableValidaty(productIdentifier: productIdentifier, activeDays: activeDays, currentDate: currentDate)
        return status
    }
    public func isNonRenewableActive(productIdentifier: String, validForMonth month: Int, currentDate: Date) throws -> Bool {
        let activeDays = month * 30
        let status = try isNonRenewableActive(productIdentifier: productIdentifier, validForDay: activeDays, currentDate: currentDate)
        return status
    }
    public func isNonRenewableActive(productIdentifier: String, validForYear year: Int, currentDate: Date) throws -> Bool {
        let activeDays = year * 365
        let status = try isNonRenewableActive(productIdentifier: productIdentifier, validForDay: activeDays, currentDate: currentDate)
        return status
    }
    
    private func checkNonRenewableValidaty(productIdentifier: String, activeDays: Int, currentDate: Date) throws -> Bool {
        if !containsPurchase(ofProductIdentifier: productIdentifier) {
            throw PurchaseDataError.productNotPurchased
        }
        
        let purchaseItem = allPurchasesByProductId(ofProductIdentifier: productIdentifier).first
        
        if purchaseItem?.expiresDate != nil {
            throw PurchaseDataError.notNonRenewableProduct
        }
        guard let purchaseDate = purchaseItem?.purchaseDate else {
            throw PurchaseDataError.purchaseDateNotAvailable
        }
        if (purchaseDate + TimeInterval(activeDays * 24 * 60 * 60)) > currentDate {
            return true
        }
        return false
    }
}
