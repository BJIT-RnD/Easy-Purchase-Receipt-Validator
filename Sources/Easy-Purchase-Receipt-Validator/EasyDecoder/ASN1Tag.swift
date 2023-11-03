//  ASN1Tag.swift

import Foundation

/**
 `ASN1Tag` represents an ASN.1 tag, which is a fundamental component in ASN.1-encoded data structures. It is responsible for specifying the class and type of an ASN.1 element, as well as whether it is constructed or primitive.

 Key Properties:
 - `constructedTag`: A constant value (0x20) used to determine if the tag is constructed.
 - `rawValue`: The raw value of the ASN.1 tag, which encodes class and type information.

 Enums:
 - `TypeClass`: An enumeration representing the class of the ASN.1 tag.
 - `Number`: An enumeration representing the tag number of the ASN.1 tag.

 Methods:
 - `tagClass()`: Get the class of the ASN.1 tag.
 - `isPrimitive()`: Check if the ASN.1 tag is primitive.
 - `isConstructed()`: Check if the ASN.1 tag is constructed.
 - `tagNumber()`: Get the tag number of the ASN.1 tag.
 - `description`: Return a description of the ASN.1 tag.

 This class is essential for interpreting ASN.1 data structures and understanding the nature of ASN.1 tags, making it suitable for data parsing and serialization tasks.
 */
public final class ASN1Tag {
    /// The value 0x20 was used in your specific example as the constructed tag because it corresponds to the binary representation 00100000. This binary representation has the most significant bit set (the leftmost bit is 1), which is a characteristic of constructed tags in ASN.1.
    let constructedTag: UInt8 = 0x20
    var rawValue: UInt8
    var tagNumber: ASN1Tag.Number {
        return Number(rawValue: rawValue & 0x1F) ?? .endOfContent
    }

    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    // Enum to represent the class of the ASN.1 tag
    public enum TypeClass: UInt8 {
        case universal = 0x00
        case application = 0x40
        case contextSpecific = 0x80
        case `private` = 0xC0
    }

    // Enum to represent the tag number of the ASN.1 tag
    public enum Number: UInt8 {
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
    // Get the class of the ASN.1 tag
    public func tagClass() -> TypeClass {
        switch rawValue {
        case TypeClass.application.rawValue:
            return .application
        case TypeClass.contextSpecific.rawValue:
            return .contextSpecific
        case TypeClass.private.rawValue:
            return .private
        default:
            return .universal
        }
    }
    // Check if the ASN.1 tag is primitive
    public func isPrimitive() -> Bool {
        return (rawValue & constructedTag) == 0
    }

    /// Used to check whether a specific ASN.1 tag is a "constructed" tag or not. In ASN.1 encoding, tags can be either constructed or primitive.
    ///
    /// - Returns: Bool. True if the AND is 1, False when the AND is 0
    public func isConstructed() -> Bool {
        return (rawValue & constructedTag) != 0
    }

//    // Get the tag number of the ASN.1 tag
    public func getTagNumber() -> Number {
        return Number(rawValue: rawValue & 0x1F) ?? .endOfContent
    }
    // Check if the ASN.1 tag represents an "End Of Content" tag
    public func isEndOfContent() -> Bool {
        return tagNumber == .endOfContent
    }

    // Check if the ASN.1 tag represents a "Null" tag
    public func isNull() -> Bool {
        return tagNumber == .null
    }

    // Check if the ASN.1 tag represents an "Object Identifier" tag
    public func isObjectIdentifier() -> Bool {
        return tagNumber == .objectIdentifier
    }

    // Check if the ASN.1 tag represents an "Integer" tag
    public func isInteger() -> Bool {
        return tagNumber == .integer
    }

    // Check if the ASN.1 tag represents a "Boolean" tag
    public func isBoolean() -> Bool {
        return tagNumber == .boolean
    }

    // Check if the ASN.1 tag represents a string type (UTF-8, printable, general, universal, character, T.61)
    public func isString() -> Bool {
        return tagNumber == .utf8String || tagNumber == .printableString || tagNumber == .generalString || tagNumber == .universalString || tagNumber == .characterString || tagNumber == .t61String
    }

    // Check if the ASN.1 tag represents a "BMP String" tag
    public func isBmpString() -> Bool {
        return tagNumber == .bmpString
    }

    // Check if the ASN.1 tag represents a string type (IA5 or Visible)
    public func isVisibleString() -> Bool {
        return tagNumber == .ia5String || tagNumber == .visibleString
    }

    // Check if the ASN.1 tag represents a "UTC Time" tag
    public func isUTCTime() -> Bool {
        return tagNumber == .utcTime
    }

    // Check if the ASN.1 tag represents a "Generalized Time" tag
    public func isGeneralizedTime() -> Bool {
        return  tagNumber == .generalizedTime
    }

    // Check if the ASN.1 tag represents a "Bit String" tag
    public func isBit() -> Bool {
        return  tagNumber == .bitString
    }

    // Check if the ASN.1 tag represents an "Octet String" tag
    public func isOctet() -> Bool {
        return  tagNumber == .octetString
    }

    // Return a description of the ASN.1 tag
    public var description: String {
        if tagClass() == .universal {
            return String(describing: tagNumber)
        } else {
            return "\(tagClass())(\(tagNumber.rawValue))"
        }
    }
}
