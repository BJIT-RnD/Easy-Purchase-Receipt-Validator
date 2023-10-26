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
    /// Store the raw byte value of ASN1Object
    public var rawValue: Data?
    /// This property contains ASN1 decoded Swift object whenever is possible
    public var value: Any?
    /// Hold reference of child ASN1Objects
    var childs: [ASN1Object]?
    /// Hold the reference of parent ASN1Object
    public internal(set) weak var parent: ASN1Object?
}
