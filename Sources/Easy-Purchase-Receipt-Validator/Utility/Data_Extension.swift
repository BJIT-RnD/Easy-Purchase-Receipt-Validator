/**
 File Name: `Data_Extension.swift`
 
 Description: This file contains the implementation of the `Data_Extension`, which is responsible for giving `uint64` value.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

import Foundation
extension Data {
    /**
     Example - [0x4A, 0x6F, 0x68, 0x6E, 0x6E]
     value = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
     0x4A = 01001010
     value += 01001010 means
     value = 00000000 00000000 00000000 00000000 00000000 00000000 00000000 01001010
     now left shift << UInt64(8*(count-index-1)) means = << 8*(5-0-1) = <<32
     updated value = 00000000 00000000 00000000 01001010 00000000 00000000 00000000 00000000
     After finish for loop the value will be.
     value = 00000000  00000000  00000000  01001010  01101111  01101000  01101110  01101110
     */
    public var uint64Value: UInt64? {
        guard count <= 8, !isEmpty else { // check if suitable for UInt64
            return nil
        }
        var value: UInt64 = 0
        for (index, byte) in self.enumerated() {
            value += UInt64(byte) << UInt64(8 * (count - index - 1))
        }
        return value
    }
}
