/**
 File Name: `CertificateParser.swift`
 
 Description: This file contains the implementation of the `CertificateParser` class, which is responsible for parsing X509Certificate and get all important fields.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */
import Foundation
import Security

final class CertificateParser {
    private let dataBlock: ASN1Object
    private let mainAsn1Object: ASN1Object
    
    enum X509BlockPosition: Int {
        case version = 0
        case serialNumber = 1
        case signatureAlg = 2
        case issuer = 3
        case dateValidity = 4
        case subject = 5
        case publicKey = 6
        case extensions = 7
    }
    
    init<obj:ASN1Object> (asn1: obj) throws {
        guard let firstBlock = asn1.childASN1Object(at: 0) else { throw ASN1Error.parseError }
        self.mainAsn1Object = asn1
        self.dataBlock = firstBlock
    }
    
    /// Checks that the given date is within the certificate's validity period.
    public func checkValidity(_ date: Date = Date()) -> Bool {
        if let notBefore = notBefore, let notAfter = notAfter {
            return date > notBefore && date < notAfter
        }
        return false
    }
    
    /// Gets the notBefore date from the validity period of the certificate.
    private var notBefore: Date? {
        return dataBlock[X509BlockPosition.dateValidity]?.childASN1Object(at: 0)?.value as? Date
    }

    /// Gets the notAfter date from the validity period of the certificate.
    private var notAfter: Date? {
        return dataBlock[X509BlockPosition.dateValidity]?.childASN1Object(at: 0)?.value as? Date
    }
    
}
