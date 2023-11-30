/**
 File Name: `ASN1Object_Certificate_Extension.swift`
 
 Description: This file contains the extension of the `ASN1Object` class, which is responsible for accessing certificate index properly.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

import Foundation
extension ASN1Object {
    subscript(index: CertificateParser.X509BlockPosition) -> ASN1Object? {
        guard let childs = childs else { return nil }
        if childs.count <= 6 {
            guard childs.indices.contains(index.rawValue - 1) else { return nil }
            return childs[index.rawValue - 1]
        } else {
            guard childs.indices.contains(index.rawValue) else { return nil }
            return childs[index.rawValue]
        }
    }
}
