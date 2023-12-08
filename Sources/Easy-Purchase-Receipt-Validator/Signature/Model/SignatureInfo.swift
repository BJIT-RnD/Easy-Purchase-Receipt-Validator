/**
 File Name: `SignatureInfo.swift`
 
 Description: This file contains the implementation of the `SignatureInfo` class, which is responsible to create model for Apple receipt signature.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

import Foundation
/*
 https://tools.ietf.org/html/rfc5652#section-5.3
SignerInfo ::= SEQUENCE {
        version CMSVersion,
        sid SignerIdentifier,
        digestAlgorithm DigestAlgorithmIdentifier,
        signedAttrs [0] IMPLICIT SignedAttributes OPTIONAL,
        signatureAlgorithm SignatureAlgorithmIdentifier,
        signature SignatureValue,
        unsignedAttrs [1] IMPLICIT UnsignedAttributes OPTIONAL }
*/
public class SignatureInfo {
    /// The version of the Signature info. Should be 1
    public let version: ASN1Object?
    /// Contains information about the signing certificate, like commonName, OU, organization, country
    public let signerIdentifier: ASN1Object?
    /// The identifier for the algorithm that was used to sign
    public let digestAlgorithmIdentifier: ASN1Object?
    /// Contains information how the signature was created. A set with a sequence. First entry is the hashing algorithm. Second is the signature algorithm (not sure if this is valid for all pkcs files)
    public let signedAttributes: ASN1Object?
    /// Algorithm used to create the signature
    public let signatureAlgorithm: ASN1Object?
    /// The actual signature
    public let signature: ASN1Object?
    
    public var signatureData: Data? {
        return signature?.rawValue
    }
    
    public var disgestAlgorithmName: String? {
        guard let oid = self.digestAlgorithmOID else {return nil}
        return String(describing: oid)
    }
    
    public var digestAlgorithmOID: OID? {
        let value = digestAlgorithmIdentifier?.childASN1Object(at: 0)?.value as? String ?? ""
        return OID(rawValue: value)
    }
    
    public var signatureAlgorithmName: String? {
        guard let oid = self.signatureAlgorithmOID else {return nil}
        return String(describing: oid)
    }
    
    public var signatureAlgorithmOID: OID? {
        let value = signatureAlgorithm?.childASN1Object(at: 0)?.value as? String ?? ""
        return OID(rawValue: value)
    }
    public init(asn1: ASN1Object) {
        self.version = asn1.childASN1Object(at: 0)
        self.signerIdentifier = asn1.childASN1Object(at: 1)
        self.digestAlgorithmIdentifier = asn1.childASN1Object(at: 2)
        let sub3 = asn1.childASN1Object(at: 3)
        if sub3?.identifier?.typeClass() == ASN1Identifier.Class.contextSpecific {
            self.signedAttributes = sub3
            self.signatureAlgorithm = asn1.childASN1Object(at: 4)
            self.signature = asn1.childASN1Object(at: 5)
        } else {
            self.signedAttributes = nil
            self.signatureAlgorithm = sub3
            self.signature = asn1.childASN1Object(at: 4)
        }
    }
}
