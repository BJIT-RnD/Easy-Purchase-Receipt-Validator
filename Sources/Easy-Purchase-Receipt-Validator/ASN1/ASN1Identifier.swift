//
//  File.swift
//  
//
//  Created by Admin on 23/10/23.
//

import Foundation
/**
 The ASN.1 identifier specifies the data type of the value component within the ASN.1 object. It serves as a way to identify and categorize the data within the ASN1 object.

The ASN.1 identifier typically consists of two parts
- parameters:
 - Class : Specifies the encoding class of the ASN.1 object. The class can have one of the following values
 - Tag : Specifies the type of the ASN.1 object within the class. The tag value is typically a numeric value assigned to a specific data type. For example, the tag value for INTEGER is 2
 */

public class ASN1Identifier {
    public enum Class: UInt8 {
        case universal = 0x00
        case application = 0x40
        case contextSpecific = 0x80
        case `private` = 0xC0
    }
    
    public enum TagNumber: UInt8 {
        case endOfContent = 0x00
        case boolean = 0x01
        case integer = 0x02
        case bitString = 0x03
        case octetString = 0x04
        case null = 0x05
        case objectIdentifier = 0x06
        case objectDescriptor = 0x07
        case external = 0x08
        case read = 0x09
        case enumerated = 0x0A
        case embeddedPdv = 0x0B
        case utf8String = 0x0C
        case relativeOid = 0x0D
        case sequence = 0x10
        case set = 0x11
        case numericString = 0x12
        case printableString = 0x13
        case t61String = 0x14
        case videotexString = 0x15
        case ia5String = 0x16
        case utcTime = 0x17
        case generalizedTime = 0x18
        case graphicString = 0x19
        case visibleString = 0x1A
        case generalString = 0x1B
        case universalString = 0x1C
        case characterString = 0x1D
        case bmpString = 0x1E
    }
    
    var rawValue: UInt8
    let constructedTag: UInt8 = 0x20
    
    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}
