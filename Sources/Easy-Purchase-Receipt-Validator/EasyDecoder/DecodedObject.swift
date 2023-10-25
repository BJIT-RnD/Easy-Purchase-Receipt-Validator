//
//  File.swift
//  
//
//  Created by BJIT on 25/10/23.
//

import Foundation

/**
 `DecodedObject` represents a parsed object within an ASN.1-encoded data structure. It serves as a flexible container for storing decoded data and managing sub-objects.

 Key Properties:
 - `rawValue`: The original binary data provided by Apple, typically in ASN.1 format.
 - `value`: The decoded or parsed value, which can be of various data types.
 - `sub`: An array of `DecodedObject` instances, storing sub-objects within the structure.
 - `parent`: A reference to the parent `DecodedObject`, if applicable.

 Primary Methods:
 - `sub(_:)`: Access a sub-object by its index.
 - `subCount()`: Get the count of sub-objects.
 - `asString`: Retrieve the value as a string, recursively searching sub-objects if necessary.

 This class simplifies working with structured data, making it suitable for data parsing and serialization tasks.
 */
public class DecodedObject: CustomStringConvertible {
    public var description: String = ""
    /// The variable containing the original data provided by Apple
    public var rawValue: Data?
    /// The variable intended to store the decoded rawValue
    public var value: Any?
    /// Generally ASN1 type object may have sub ASN1 type object. This property is intended to store the sub ASN1 objects
    var sub: [DecodedObject]?
    /// Parent of the decoded objects
    public internal(set) weak var parent: DecodedObject?
    
    /// Access a sub-object at the specified index.
    ///
    /// - Parameters:
    ///   - index: The index of the sub-object to access.
    /// - Returns: The sub-object at the specified index, or `nil` if the index is out of bounds.
    public func sub(_ index: Int) -> DecodedObject? {
        if let sub = self.sub, index >= 0, index < sub.count {
            return sub[index]
        }
        return nil
    }
    
    /// Subscript to access sub-objects by index.
    ///
    /// - Parameter index: The index of the sub-object to access.
    public subscript(index: Int) -> DecodedObject? {
        return sub(index)
    }
    
    /// Get the count of sub-objects.
    ///
    /// - Returns: The number of sub-objects, or 0 if there are none.
    public func subCount() -> Int {
        return sub?.count ?? 0
    }
    
    /// Get the value as a string, recursively searching sub-objects if necessary.
    public var asString: String? {
        if let string = value as? String {
            return string
        }
        
        for item in sub ?? [] {
            if let string = item.asString {
                return string
            }
        }
        return nil
    }
}
