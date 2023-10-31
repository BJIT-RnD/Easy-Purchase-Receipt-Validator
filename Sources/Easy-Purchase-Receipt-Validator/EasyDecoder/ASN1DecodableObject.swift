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
public final class ASN1DecodableObject: CustomStringConvertible {
    public var description: String {
        return getASN1()
    }
    /// The variable containing the original data provided by Apple
    public var rawValue: Data?
    /// The variable intended to store the decoded rawValue
    public var value: Any?
    /// Generally ASN1 type objects may have sub ASN1 type objects. This property is intended to store the sub ASN1 objects
    public var subObjects: [ASN1DecodableObject]?
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
            if element.asn1Tag?.getTagNumber() == .objectIdentifier {
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

    /// Checks if the ASN.1 tag of the object is of the universal class.
    ///
    /// - Returns: `true` if the tag is of the universal class, otherwise `false`.
    public func isUniversal() -> Bool {
        // Ensure that an ASN.1 tag is assigned to the object.
        guard let asn1Tag else {
            return false
        }
        
        // Check if the ASN.1 tag's class is .universal.
        return asn1Tag.tagClass() == .universal
    }

    
    /// This function generates an ASN.1 representation of data in a hierarchical manner.
    ///
    /// - Parameter insets: An optional parameter used to control the indentation of the ASN.1 output.

    private func getASN1(insets: String = "") -> String {
        var output = insets
        output.append(asn1Tag?.description.uppercased() ?? "")
        output.append(value != nil ? ": \(value!)" : "")
        if asn1Tag?.tagClass() == .universal, asn1Tag?.getTagNumber() == .objectIdentifier {
            if let oidName = ASN1ObjectType.getTypeName(of: value as? String ?? "") {
                output.append(" (\(oidName))")
            }
        }
        output.append(subObjects != nil && !subObjects!.isEmpty ? " {" : "")
        output.append("\n")
        for item in subObjects ?? [] {
            output.append(item.getASN1(insets: insets + "    "))
        }
        output.append(subObjects != nil && !subObjects!.isEmpty ? insets + "}\n" : "")
        return output
    }
}