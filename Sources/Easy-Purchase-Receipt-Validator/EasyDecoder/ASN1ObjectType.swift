//  ASN1ObjectType.swift

import Foundation

public enum ASN1ObjectType: String {
    case etsiQcsCompliance = "0.4.0.1862.1.1"
    case etsiQcsRetentionPeriod = "0.4.0.1862.1.3"
    case etsiQcsQcSSCD = "0.4.0.1862.1.4"
    case dsa = "1.2.840.10040.4.1"
    case ecPublicKey = "1.2.840.10045.2.1"
    case prime256v1 = "1.2.840.10045.3.1.7"
    case ecdsaWithSHA256 = "1.2.840.10045.4.3.2"
    case ecdsaWithSHA384 = "1.2.840.10045.4.3.3"
    case ecdsaWithSHA512 = "1.2.840.10045.4.3.4"
    case rsaEncryption = "1.2.840.113549.1.1.1"
    case rsaPSS = "1.2.840.113549.1.1.10"
    case sha256WithRSAEncryption = "1.2.840.113549.1.1.11"
    case md5WithRSAEncryption = "1.2.840.113549.1.1.4"
    case sha1WithRSAEncryption = "1.2.840.113549.1.1.5"
    case domainComponent = "0.9.2342.19200300.100.1.25"
    case userId = "0.9.2342.19200300.100.1.1"
    
    // Digest algorithms
    case sha1 = "1.3.14.3.2.26"
    case pkcsSha256 = "1.3.6.1.4.1.22554.1.2.1"
    case sha2Family = "1.3.6.1.4.1.22554.1.2"
    case sha3_244 = "2.16.840.1.101.3.4.2.7"
    case sha3_256 = "2.16.840.1.101.3.4.2.8"
    case sha3_384 = "2.16.840.1.101.3.4.2.9"
    case md5 = "0.2.262.1.10.1.3.2"
    
    // More types will be added later
    
    /// Get the ASN.1 object type name
    ///
    /// - Returns: The type name
    static func getTypeName(of value: String) -> String? {
        if let type = ASN1ObjectType(rawValue: value) {
            return "\(type)"
        }
        return nil
    }
}
