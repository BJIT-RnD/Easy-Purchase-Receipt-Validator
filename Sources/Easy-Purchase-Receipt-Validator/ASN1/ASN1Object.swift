/**
 File Name: `ASN1Identifier.swift`
 
 Description: This file contains the implementation of the `ASN1Identifier` class, which is responsible for managing ASN1Identifier class and tags.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

import Foundation
/// This property contains the DER encoded object
/// - Source - https://www.oss.com/asn1/resources/asn1-made-simple/encoding-rules.html

/**
 The structure of an `ASN.1` (Abstract Syntax Notation One) object typically consists of three main components. `ASN.1 Identifier, Length of the Data, Actual Data`.

 - ASN.1 Identifier: This component specifies the type or tag of the data and provides information about how to interpret the data. It includes details such as whether the data is an integer, a string, a sequence, or other data types.
 - Length of the Data: This component indicates the length of the encoded data in bytes. It can be a simple length encoding for short values or a more complex encoding for longer values.
 - Actual Data: This component contains the actual data, which is often referred to as the "content" or "value." The structure and encoding of the data depend on the ASN.1 type specified in the identifier.
 */

public final class ASN1Object {
    /// Store the ASN1Identifier of this ASN1Object
    public var identifier: ASN1Identifier?
    /// Store the raw byte value of ASN1Object value property
    public var rawValue: Data?
    /// This property contains ASN1 decoded Swift object whenever is possible
    public var value: Any?
    /// Hold reference of child ASN1Objects
    var childs: [ASN1Object]?
    /// Hold the reference of parent ASN1Object
    public internal(set) weak var parent: ASN1Object?
    public var description: String {
        return printAsn1()
    }
    
    public var asString: String? {
        if let string = value as? String {
            return string
        }
        for item in childs ?? [] {
            if let string = item.asString {
                return string
            }
        }
        return nil
    }
    
    /**
     Try to find child `ASN1Object` for given `index`
     - Parameter:
        - index : Int for which you are looking for ASN1Object
     - Reture:
        - `ASN1Object` of this `OID`
     */
    public func childASN1Object(at index: Int) -> ASN1Object? {
        guard let childs = childs,
              !childs.isEmpty && index < childs.count else { return nil }
        return childs[index]
    }
    
    public func numberOfChilds() -> Int {
        return self.childs?.count ?? 0
    }
    
    /**
     Try to find child `ASN1Object` of define `OID`
     - Parameter:
        - oid : OID for which you are looking for ASN1Object
     - Reture:
        - `ASN1Object` of this `OID`
     */
    public func findASN1Object(of oid: OID) -> ASN1Object? {
        guard let childs = childs else { return nil }
        for asn1Object in childs {
            if asn1Object.identifier?.tagNumber() == .objectIdentifier {
                if asn1Object.value as? String == oid.rawValue {
                    return asn1Object
                }
            } else {
                if let result = asn1Object.findASN1Object(of: oid) { return result }
            }
        }
        return nil
    }
    
    /**
     Give a descriptive explanation for ASN1Object
     */
    public func printAsn1(insets: String = "") -> String {
        var output = insets
        output.append(identifier?.description.uppercased() ?? "")
        if let value = value {
            output.append(": \(value)")
        } else {
            output.append("")
        }
        if identifier?.typeClass() == .universal, identifier?.tagNumber() == .objectIdentifier {
            if let oidName = OID.description(of: value as? String ?? "") {
                output.append(" (\(oidName))")
            }
        }
        if let childs = childs, !childs.isEmpty {
            output.append("{\n")
            for childASN1 in childs {
                output.append(childASN1.printAsn1(insets: insets + "    "))
            }
            output.append(insets + "}\n")
        } else {
            output.append("\n")
        }
        return output
    }
}
