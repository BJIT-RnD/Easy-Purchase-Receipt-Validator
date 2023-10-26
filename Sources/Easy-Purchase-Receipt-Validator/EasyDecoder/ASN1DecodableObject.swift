//  ASN1DecodableObject.swift

import Foundation

/**
 `ASN1DecodableObject` represents a parsed object within an ASN.1-encoded data structure. It serves as a flexible container for storing decoded data and managing sub-objects.

 Key Properties:
 - `rawValue`: The original binary data provided by Apple, typically in ASN.1 format.
 - `subObjects`: An array of `ASN1DecodableObject` instances, storing sub-objects within the structure.
 - `tag`: The ASN.1 tag associated with this object.
 - `parent`: A reference to the parent `ASN1DecodableObject`, if applicable.

 Primary Methods:
 - `subObjects(_:)`: Access a sub-object by its index.
 - `subCount()`: Get the count of sub-objects.
 - `getDecodableObject(by:)`: Retrieve a sub-object by its ASN.1 object type or tag number.
 - `asString`: Retrieve the value as a string, recursively searching sub-objects if necessary.

 This class simplifies working with structured data, making it suitable for data parsing and serialization tasks.
 */
public class ASN1DecodableObject: CustomStringConvertible {
    public var description: String = ""
    /// The variable containing the original data provided by Apple
    public var rawValue: Data?
    /// The variable intended to store the decoded rawValue
    public var value: Any?
    /// Generally ASN1 type objects may have sub ASN1 type objects. This property is intended to store the sub ASN1 objects
    var subObjects: [ASN1DecodableObject]?
    public var asn1Tag: ASN1Tag?
    /// Parent of the decoded objects
    public internal(set) weak var parent: ASN1DecodableObject?
    
    /// Access a sub-object at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the sub-object to access.
    /// - Returns: The sub-object at the specified index, or `nil` if the index is out of bounds.
    public func subObjects(_ index: Int) -> ASN1DecodableObject? {
        if let subObjects = self.subObjects, index >= 0, index < subObjects.count {
            return subObjects[index]
        }
        return nil
    }
    
    /// Subscript to access sub-objects by index.
    ///
    /// - Parameter index: The index of the sub-object to access.
    public subscript(index: Int) -> ASN1DecodableObject? {
        return subObjects(index)
    }
    
    /// Get the count of sub-objects.
    ///
    /// - Returns: The number of sub-objects, or 0 if there are none.
    public func subCount() -> Int {
        return subObjects?.count ?? 0
    }
    /// Retrieve a sub-object by its ASN.1 object type.
    ///
    /// - Parameter type: The ASN.1 object type to search for.
    /// - Returns: The sub-object with a matching object type, or `nil` if not found.
    public func getDecodableObject(by type: ASN1ObjectType) -> ASN1DecodableObject? {
        return getDecodableObject(by: type.rawValue)
    }
    /// Retrieve a sub-object by its ASN.1 tag number.
    ///
    /// - Parameter type: The ASN.1 tag number to search for.
    /// - Returns: The sub-object with a matching tag number, or `nil` if not found.
    public func getDecodableObject(by type: String) -> ASN1DecodableObject? {
        for element in subObjects ?? [] {
            if element.asn1Tag?.tagNumber() == .objectIdentifier {
                if element.value as? String == type {
                    return element
                }
            } else {
                if let result = element.getDecodableObject(by: type) {
                    return result
                }
            }
        }
        return nil
    }
    
    /// Get the value as a string, recursively searching sub-objects if necessary.
    public var asString: String? {
        if let string = value as? String {
            return string
        }
        
        for item in subObjects ?? [] {
            if let string = item.asString {
                return string
            }
        }
        return nil
    }
}