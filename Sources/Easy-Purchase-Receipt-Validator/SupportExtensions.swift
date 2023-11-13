//
//  File.swift
//  
//
//  Created by BJIT on 13/11/23.
//

import Foundation
extension Data {
    /// Converts Data to a hexadecimal-encoded string.
    ///
    /// - Parameter separation: The string used to separate each pair of hexadecimal characters.
    /// - Returns: A hexadecimal-encoded string representation of the Data.
    func hexEncodedString(separation: String = "") -> String {
        // Use reduce to concatenate each byte in hexadecimal format with the specified separation
        return reduce("") { $0 + String(format: "%02X\(separation)", $1) }
    }
}

extension String {
    /// Converts a base64-encoded string to Data.
    ///
    /// - Returns: The Data representation of the base64-encoded string.
    func dataFromBase64() -> Data? {
        // Use Data's initializer to decode the base64-encoded string
        return Data(base64Encoded: self, options: .ignoreUnknownCharacters)
    }
}
