//
//  ValidationError.swift
//  
//
//  Created by BJIT on 10/11/23.
//

import Foundation
public enum ValidationError: Error {
    case initializationFailed(reason: ReceiptInitializationFailureReason)
    case validationFailed(reason: ValidationFailureReason)
    case purchaseExpired
    case receiptRefreshingInProgress
    /// The underlying reason the receipt initialization error occurred.
    ///
    /// - appStoreReceiptNotFound:         In-App Receipt not found
    /// - pkcs7ParsingError:               PKCS7 Container can't be extracted from in-app receipt data
    public enum ReceiptInitializationFailureReason {
        case appStoreReceiptNotFound
        case pkcs7ParsingError
        case dataIsInvalid
    }

    /// The underlying reason the receipt validation error occurred.
    ///
    /// - hashValidation:          Computed hash doesn't match the hash from the receipt's payload
    /// - signatureValidation:     Error occurs during signature validation. It has several reasons to failure
    public enum ValidationFailureReason {
        case hashValidation
        case signatureValidation(SignatureValidationFailureReason)
        case bundleIdentifierVerification
        case bundleVersionVerification
    }

    /// The underlying reason the signature validation error occurred.
    ///
    /// - appleIncRootCertificateNotFound:          Apple Inc Root Certificate Not Found
    /// - unableToLoadAppleIncRootCertificate:      Unable To Load Apple Inc Root Certificate
    /// - receiptIsNotSigned:                       The receipt doesn't contain a signature
    /// - receiptSignedDataNotFound:                The receipt does contain somr signature, but there is an error while creating a signature object
    /// - invalidSignature:                         The receipt contains invalid signature
    public enum SignatureValidationFailureReason {
        case appleIncRootCertificateNotFound
        case unableToLoadAppleIncRootCertificate
        case unableToLoadAppleIncPublicKey
        case unableToLoadiTunesCertificate
        case unableToLoadiTunesPublicKey
        case unableToLoadWorldwideDeveloperCertificate
        case unableToLoadAppleIncPublicSecKey
        case receiptIsNotSigned
        case receiptSignedDataNotFound
        case receiptDataNotFound
        case signatureNotFound
        case invalidSignature
        case invalidCertificateChainOfTrust
    }
}
