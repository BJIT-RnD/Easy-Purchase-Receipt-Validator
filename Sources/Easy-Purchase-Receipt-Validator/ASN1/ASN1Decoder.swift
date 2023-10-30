/**
 File Name: `ASN1Decoder.swift`
 
 Description: This file contains the implementation of the `ASN1Decoder` class, which is responsible for parssing ASN1Decoder.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */
import Foundation

enum ASN1Error: Error {
    case parseError
    case outOfBuffer
}

class ASN1Decoder {
 //
}

// MARK: - ASN1Object actual data length
extension ASN1Decoder {
    /**
     it returns the length value as a UInt64, which represents the number of bytes needed to represent the content within the ASN.1 object
     
     1. In ASN.1 encoding, the length field can be encoded in one of two forms: `short form and long form`. `8th` bit of the byte is a `flag` which represent either it's `short` form or `long` form. If it's `1` then `long form` and if it's `0` then `short form`.
     
     - `Short Form`: If the length can be represented in a single byte (i.e., the length is less than or equal to `127/2^7`), it is encoded in the short form. Here it's not `2^8` because last bit preserve for the `flag`.
     - `Long Form`: If the length requires more than one byte to represent (i.e., the length is 128 or greater), it is encoded in the long form. 8th bit of the initial byte must be `1`.
     
     2. In the `long` form, the first byte (the length byte) has a special bit pattern: bit `8th` (the high-order bit) is set to `1`, and the remaining bits (`7 through 1`) indicate how many subsequent bytes should be used to represent the actual length.
     
     3. To determine the number of bytes used to represent the length in the long form, you subtract `0x80` (which is 128 in decimal) from the value of the `first length byte`. This subtraction gives you the count of additional bytes used for the length.
     
     For example, let's say the first length byte is `0x87`. Here's how the calculation works:
     
     - The value of `0x87` in decimal is `135`.
     - Subtracting `0x80` from `0x87` results in `0x07`, which is `7` in decimal.
     - This means that there are `7` additional bytes following the first length byte to represent the actual length.
     
     So, in the code `let octetsToRead = first! - 0x80`, the subtraction of `0x80` is a way to extract the count of additional bytes used in the `long` form to represent the `length`. This value (`octetsToRead`) is then used to read the actual bytes representing the `length` from the iterator.
     */
    func getContentLength(iterator: inout Data.Iterator) -> UInt64 {
        let firstByte = iterator.next()
        guard let firstByte = firstByte else {
            return 0
        }
        if firstByte & 0x80 != 0 {
            let octetsToRead = firstByte - 0x80
            var data = Data()
            for _ in 0..<octetsToRead {
                if let n = iterator.next() {
                    data.append(n)
                }
            }
            return data.uint64Value ?? 0
        }
        return UInt64(firstByte)
    }
    /**
     Responsible to load child content
     - Parameter:
        - iterator: Give a start pointer from the asn1 length
     - Return: Child content as `Data`
     */
    func loadChildContent(iterator: inout Data.Iterator) throws -> Data {
        let len = self.getContentLength(iterator: &iterator)
        guard len < Int.max else {
            return Data()
        }
        var byteArray: [UInt8] = []
        for _ in 0..<Int(len) {
            if let n = iterator.next() {
                byteArray.append(n)
            } else {
                throw ASN1Error.outOfBuffer
            }
        }
        return Data(byteArray)
    }
}
