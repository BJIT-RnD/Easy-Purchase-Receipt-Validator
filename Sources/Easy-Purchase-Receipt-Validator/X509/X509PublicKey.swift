/**
 File Name: `X509PublicKey.swift`
 
 Description: This file contains the implementation of the `X509PublicKey` class, which is responsible for modeling and parsing X509PublicKey.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */
/* Sample example
 
 SEQUENCE{
     SEQUENCE{
         OBJECTIDENTIFIER: 1.2.840.113549.1.1.1 (rsaEncryption)
         NULL
     }
     BITSTRING: 270 bytes
 }
*/

import Foundation
class X509PublicKey {
    let pkBlock: ASN1Object

    init(pkBlock: ASN1Object) {
        self.pkBlock = pkBlock
    }
    var algOid: String? {
        return pkBlock.childASN1Object(at: 0)?.childASN1Object(at: 0)?.value as? String
    }
    var algName: String? {
        return OID.description(of: algOid ?? "")
    }
    var algParams: String? {
        return pkBlock.childASN1Object(at: 0)?.childASN1Object(at: 1)?.value as? String
    }
    
    var key: Data? {
        guard
            let algOid = algOid,
            let oid = OID(rawValue: algOid),
            let keyData = pkBlock.childASN1Object(at: 1)?.value as? Data else {
                return nil
        }

        switch oid {
        case .ecPublicKey:
            return keyData

        case .rsaEncryption:
            let decoder = ASN1Decoder()
            guard let publicKeyAsn1Objects = (try? decoder.decode(data: keyData)) else {
                return nil
            }
            guard let publicKeyModulus = publicKeyAsn1Objects.first?.childASN1Object(at: 0)?.value as? Data else {
                return nil
            }
            return publicKeyModulus
        default:
            return nil
        }
    }
}
