/**
 File Name: `SignatureDecoder.swift`
 
 Description: This file contains the implementation of the `SignatureDecoder` class, which is responsible to decode `SignatureInfo` from given `ASN1Object`.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

enum SignatureDecoder {
    static func retriveSignature(from signerInfos: ASN1Object) -> [SignatureInfo] {
        let numberOfSignatures = signerInfos.numberOfChilds()
        var signatures: [SignatureInfo] = []
        for i in 0..<numberOfSignatures {
            guard let signatureInfoasn1 = signerInfos.childASN1Object(at: i) else {continue}
            let sigInfo = SignatureInfo(asn1: signatureInfoasn1)
            signatures.append(sigInfo)
        }
        return signatures
    }
}
