/**
 File Name: `ASN1Identifier.swift`
 
 Description: This file contains the implementation of the `ASN1Identifier` class, which is responsible for managing ASN1Identifier class and tags.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

import Foundation
/**
 The ASN.1 identifier specifies the data type of the value component within the ASN.1 object. It serves as a way to identify and categorize the data within the ASN1 object.

The ASN.1 identifier typically consists of two parts. `Class & Tag. First 2 digit represent class and last 6 digit represent tag`
- parameters:
 
 - `Class` : Specifies the encoding class of the ASN.1 object. The class can have one of the following values. Here you cas see the change of last 2 digit.
 
 case `universal`                 = 0x00       =      `00000000`
 case `application`             = 0x40      =      `01000000`
 case `contextSpecific`     = 0x80      =      `10000000`
 case `private`                      = 0xC0     =     `11000000`
 
 - `Tag` : Specifies the type of the ASN.1 object within the class. The 1st digit in between 6 digit represent the tag type(`Primitive or Constructed`). Last 5 digit represent the actual tag number. The tag value is typically a numeric value assigned to a specific data type. For example, the tag value 2 means the data inside is an integer
 
 - `An Example`: `0X30`
 binary = `00110000`
 first 2 digit = 00 represent it's a `universal class`
 6th digit from the last = 1 represent it's a `Constructed` tag
 last 5 digit = 10000 represent it's a `sequence` type tage as `sequence value is 0x10`
 */

public final class ASN1Identifier: CustomStringConvertible {
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
    
    func typeClass() -> Class {
        for classType in [Class.application, Class.contextSpecific, Class.private] where (rawValue & classType.rawValue) == classType.rawValue {
            return classType
        }
        return .universal
    }
    
    /**
     Get the 6th digit of the rawvalue. If it's not set, then it's primitive
     */
    public func isPrimitive() -> Bool {
        return (rawValue & self.constructedTag) == 0
    }
    
    /**
     Get the 6th digit of the rawvalue. If it's set, then it's constructed
     */
    public func isConstructed() -> Bool {
        return (rawValue & self.constructedTag) != 0
    }
    
    /**
     Get last 5 digit. As the maximum tag number 0x1E = 00011110. Set upto 5 digit from right.
     */
    public func tagNumber() -> TagNumber {
        return TagNumber(rawValue: rawValue & 0x1F) ?? .endOfContent
    }
    
    public var description: String {
        if typeClass() == .universal {
            return String(describing: tagNumber())
        } else {
            return "\(typeClass())(\(tagNumber().rawValue))"
        }
    }
}
