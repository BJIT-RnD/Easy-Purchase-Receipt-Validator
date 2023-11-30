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
    case lengthEncodingError
    case childContentEncodingError
}
enum ASN1Status: Error {
    case endOfContent
}

public class ASN1Decoder {
    /**
     Return list of ASN1Object from the given data.
     - Parameters:
        - data : Give receipt as a data
     - Returns: List of `ASN1Object`.
     */
    func decode(data: Data) throws -> [ASN1Object] {
        var iterator = data.makeIterator()
        return try parse(iterator: &iterator)
    }
    
    /**
     Return list of ASN1Object from the given data.
     - Parameters:
        - iterator: Give the initial pointer
     - Returns: List of `ASN1Object` as an array.
     */
    func parse(iterator: inout Data.Iterator) throws -> [ASN1Object] {
        var result: [ASN1Object] = []
        while let nextASN1ObjectPointer = iterator.next() {
            var asn1Object = ASN1Object()
            var totalASN1ObjInUInt8Form = [UInt8]()
            totalASN1ObjInUInt8Form.append(nextASN1ObjectPointer)
            asn1Object.identifier = ASN1Identifier(rawValue: nextASN1ObjectPointer)
            
            guard let isConstructed = asn1Object.identifier?.isConstructed() else {
                return result
            }
            if isConstructed {
                let contentData = try loadChildContent(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
                if contentData.isEmpty {
                    asn1Object.childs = try parse(iterator: &iterator)
                } else {
                    var subIterator = contentData.makeIterator()
                    asn1Object.childs = try parse(iterator: &subIterator)
                }
                asn1Object.value = nil
                asn1Object.rawValue = Data(contentData)
                asn1Object.asn1Container = totalASN1ObjInUInt8Form
                asn1Object.childs?.forEach({ $0.parent = asn1Object })
            } else {
                if asn1Object.identifier?.typeClass() == .universal {
                    do {
                        try self.handleUniversalClassTypeIdentifire(asn1obj: &asn1Object, atIteratio: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
                    } catch _ as ASN1Status {
                        return result
                    }
                } else {
                    try self.handleOthersClassTypeIdentifire(asn1obj: &asn1Object, atIteratio: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
                }
            }
            result.append(asn1Object)
        }
        return result
    }
    
    /**
     It will decode `.universal` class type identifire `ASN1Object` and set `value` into this ASN1Object.
     - Parameters:
        - asn1obj: Send an `ASN1Object`. It's `rawValue` & `value` property need to be set.
        - iterator: Give the pointer of the data
     */
    private func handleUniversalClassTypeIdentifire(asn1obj: inout ASN1Object, atIteratio iterator: inout Data.Iterator, totalASN1ObjInUInt8Form: inout [UInt8]) throws {
        var contentData = try loadChildContent(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
        asn1obj.rawValue = Data(contentData)
        asn1obj.asn1Container = totalASN1ObjInUInt8Form
        switch asn1obj.identifier?.tagNumber() {
        case .endOfContent:
            throw ASN1Status.endOfContent
            
        case .boolean:
            if let value = contentData.first {
                asn1obj.value = value > 0 ? true : false
            }
            
        case .integer:
            while contentData.first == 0 {
                contentData.remove(at: 0) // remove all zeros which appear in first
            }
            asn1obj.value = contentData
            
        case .null:
            asn1obj.value = nil
            
        case .objectIdentifier:
            asn1obj.value = decodeOid(contentData: &contentData)
            
        case .utf8String,
                .printableString,
                .numericString,
                .generalString,
                .universalString,
                .characterString,
                .t61String:
            
            asn1obj.value = String(data: contentData, encoding: .utf8)
            
        case .bmpString:
            asn1obj.value = String(data: contentData, encoding: .unicode)
            
        case .visibleString,
                .ia5String:
            asn1obj.value = String(data: contentData, encoding: .ascii)
            
        case .utcTime:
            asn1obj.value = dateFormatter(contentData: &contentData, formats: ["yyMMddHHmmssZ", "yyMMddHHmmZ"])
            
        case .generalizedTime:
            asn1obj.value = dateFormatter(contentData: &contentData, formats: ["yyyyMMddHHmmssZ"])
            
        case .bitString:
            if !contentData.isEmpty {
                _ = contentData.remove(at: 0) // unused bits
            }
            asn1obj.value = contentData
            
        case .octetString:
            do {
                var subIterator = contentData.makeIterator()
                asn1obj.childs = try parse(iterator: &subIterator)
            } catch {
                if let str = String(data: contentData, encoding: .utf8) {
                    asn1obj.value = str
                } else {
                    asn1obj.value = contentData
                }
            }
        default:
            // print("unsupported tag: \(asn1obj.identifier!.tagNumber())")
            asn1obj.value = contentData
        }
    }
    
    /**
     It will decode other class type identifire `ASN1Object` and set `value` into this ASN1Object.
     
     Here other class type are `.application`, `.contextSpecific`, `.private`
     - Parameters:
        - asn1obj: Send an `ASN1Object`. It's `rawValue` & `value` property need to be set.
        - iterator: Give the pointer of the data
     */
    private func handleOthersClassTypeIdentifire(asn1obj: inout ASN1Object, atIteratio iterator: inout Data.Iterator, totalASN1ObjInUInt8Form: inout [UInt8]) throws {
        let contentData = try loadChildContent(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
        asn1obj.rawValue = Data(contentData)
        asn1obj.asn1Container = totalASN1ObjInUInt8Form
        asn1obj.value = String(data: contentData, encoding: .utf8) != nil ? String(data: contentData, encoding: .utf8) : contentData
    }
}


extension ASN1Decoder {
    /**
     Give the `OID` as data and it will return `OID` as string.
     
     The `first byte` represents the first `two` components of the OID.
     
     - `The first component is obtained by dividing the byte by 40, and the second component is obtained by taking the remainder when the byte is divided by 40.` These two components are separated by a dot` (".")` and appended to the oid string.
     
     - for remaining(2nd to last) bytes calculation:
     1st bit = 0/1 represent is it `continious` or `end`? `0` means `end` and `1` means `continious`. If it's continious you have to consider the next bit also and so on.
     `2nd to 8th` bit of the `2nd byte` represent the data
     `t  << 7` Represent left shift `t` in `7` bit. That means our last `7 bit of t = 0000000`
     `(n & 0x7F)` Get the `2nd to 8th` bit contents of that byte. As `0x7F = 01111111`
     now `t = (t << 7) | (n & 0x7F)` , As it's an `or` operator so here we get the previous `t` and new `2nd to 8th bit` data of n
     `(n & 0x80) == 0`  check the last bit set or not. If it's `0` then it's not continious. If not continious then we apend it and set  `t = 0`
     
     - EX:-
     Suppose you have the encoded OID: `0x60, 0x86, 0x48, 0x1, 0x65, 0x3, 0x4, 0x2, 0x1`, which decodes to the string `"2.16.840.1.101.3.4.2.1"`.
     let's decode using our function
     */
    func decodeOid(contentData: inout Data) -> String? {
        if contentData.isEmpty {
            return nil
        }

        var oid: String = ""

        let first = Int(contentData.remove(at: 0))
        oid.append("\(first / 40).\(first % 40)")

        var t = 0
        while !contentData.isEmpty {
            let n = Int(contentData.remove(at: 0))
            t = (t << 7) | (n & 0x7F)
            if (n & 0x80) == 0 {
                oid.append(".\(t)")
                t = 0
            }
        }
        return oid
    }
    
    /**
     Give you a formated `date`
     - Parameters:
        - contentData: Give the content data
        - formats: Array of formatted string
    - Returns: Get back to formatted date
     */
    func dateFormatter(contentData: inout Data, formats: [String]) -> Date? {
        guard let str = String(data: contentData, encoding: .utf8) else { return nil }
        for format in formats {
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.dateFormat = format
            if let dt = fmt.date(from: str) {
                return dt
            }
        }
        return nil
    }
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
    func getContentLength(iterator: inout Data.Iterator, totalASN1ObjInUInt8Form: inout [UInt8]) throws -> UInt64 {
        let firstByte = iterator.next()
        guard let firstByte = firstByte else {
            return 0
        }
        totalASN1ObjInUInt8Form.append(firstByte)
        if firstByte & 0x80 != 0 {
            let octetsToRead = firstByte - 0x80
            var data = Data()
            for _ in 0..<octetsToRead {
                if let singleData = iterator.next() {
                    data.append(singleData)
                    totalASN1ObjInUInt8Form.append(singleData)
                } else {
                    throw ASN1Error.lengthEncodingError
                }
            }
            return data.uint64Value ?? 0
        }
        return UInt64(firstByte)
    }
    /**
     Return child content as data
     
     give the pointer from the length of the ASN1 object and then it return child ASN1 object
     - Parameters:
        - iterator: Give a start pointer from the asn1 length
     - Returns: Child content as `Data`
     */
    func loadChildContent(iterator: inout Data.Iterator, totalASN1ObjInUInt8Form: inout [UInt8]) throws -> Data {
        let len = try self.getContentLength(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
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
        totalASN1ObjInUInt8Form.append(contentsOf: byteArray)
        return Data(byteArray)
    }
}


// MARK: Extension for unit test
extension ASN1Decoder {
    func test_handleOthersClassTypeIdentifire(asn1obj: inout ASN1Object, atIteratio iterator: inout Data.Iterator, totalASN1ObjInUInt8Form: inout [UInt8]) throws {
        try handleOthersClassTypeIdentifire(asn1obj: &asn1obj, atIteratio: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
    }
    
    func test_handleUniversalClassTypeIdentifire(asn1obj: inout ASN1Object, iterator: inout Data.Iterator, totalASN1ObjInUInt8Form: inout [UInt8]) throws {
        try handleUniversalClassTypeIdentifire(asn1obj: &asn1obj, atIteratio: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
    }
}
