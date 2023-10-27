//  EasyDecoder.swift

import Foundation

/**
 `EasyDecoder` is a utility class designed to simplify the process of decoding ASN.1-encoded data into an array of `ASN1DecodableObject` instances.

 Primary Methods:
 - `decodeData(data:)`: Decodes ASN.1 data and returns an array of `ASN1DecodableObject` instances.

 Internal Methods:
 - `process(iterator:)`: Processes the ASN.1 data iterator and generates an array of `ASN1DecodableObject` instances.

 Usage:
 - Create an instance of `EasyDecoder`.
 - Call `decodeData(data:)` to decode ASN.1 data and obtain an array of decodable objects.

 This class is intended to aid in the initial stages of ASN.1 data decoding and can be extended for more advanced ASN.1 parsing functionality.
 */
public final class EasyDecoder {
    /**
     Decodes ASN.1-encoded data and returns an array of `ASN1DecodableObject` instances.

     - Parameter data: The ASN.1-encoded data to be decoded.
     - Returns: An array of `ASN1DecodableObject` instances representing the decoded data.
     - Throws: An error if decoding encounters an issue.
     */
    public static func decodeData(data: Data) throws -> [ASN1DecodableObject] {
        var iterator = data.makeIterator()
        return try process(iterator: &iterator)
    }

    /**
     Processes the ASN.1 data iterator and generates an array of `ASN1DecodableObject` instances.

     - Parameter iterator: An iterator over ASN.1-encoded data.
     - Returns: An array of `ASN1DecodableObject` instances representing the decodable data.
     - Throws: An error if decoding encounters an issue.

     This method processes the iterator, creating and configuring `ASN1DecodableObject` instances for each ASN.1 tag found in the data. It is currently a stub and needs further implementation for handling constructed ASN.1 data.
     */
    private static func process(iterator: inout Data.Iterator) throws -> [ASN1DecodableObject] {
        var decodableObjects: [ASN1DecodableObject] = []
        
        while let nextValue = iterator.next() {
            let tempObj = ASN1DecodableObject()
            tempObj.asn1Tag = ASN1Tag(rawValue: nextValue)

            // TODO:

            decodableObjects.append(tempObj)
        }
        return decodableObjects
    }
}
