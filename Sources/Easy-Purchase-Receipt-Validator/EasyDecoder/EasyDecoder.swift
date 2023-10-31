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
    
    /// Processes an ASN.1 data iterator and generates an array of `ASN1DecodableObject` instances representing the decoded data.
    ///
    /// - Parameter iterator: An iterator over ASN.1-encoded data.
    /// - Returns: An array of `ASN1DecodableObject` instances representing the decodable data.
    /// - Throws: An error if decoding encounters an issue.
    private static func process(iterator: inout Data.Iterator) throws -> [ASN1DecodableObject] {
        var decodableObjects: [ASN1DecodableObject] = []
        
        // Loop through the iterator to process ASN.1 tags.
        while let value = iterator.next() {
            let tempObj = ASN1DecodableObject()
            
            // Set the ASN.1 tag for the current object.
            tempObj.asn1Tag = ASN1Tag(rawValue: value)
            
            // Check if the ASN.1 tag is constructed.
            if tempObj.asn1Tag!.isConstructed() {
                // If the tag is constructed, decode its contents.
                let contents = try decodeContents(iterator: &iterator)
                
                if contents.isEmpty {
                    // If the contents are empty, recursively process subobjects.
                    tempObj.subObjects = try process(iterator: &iterator)
                } else {
                    // If there are contents, process subobjects based on the contents.
                    var subIterator = contents.makeIterator()
                    tempObj.subObjects = try process(iterator: &subIterator)
                }
                
                // Reset value and set the rawValue.
                tempObj.value = nil
                tempObj.rawValue = Data(contents)
                
                // Set the parent object for subobjects.
                for item in tempObj.subObjects! {
                    item.parent = tempObj
                }
            } else if tempObj.isUniversal() {
                // Handle universal tags with specific logic.
                var contents = try decodeContents(iterator: &iterator)
                tempObj.rawValue = Data(contents)
                
                // Get the ASN.1 tag of the object.
                guard let tag = tempObj.asn1Tag else {
                    return decodableObjects
                }
                
                // Check the type of the universal tag and perform specific decoding.
                if tag.isEndOfContent() {
                    return decodableObjects
                } else if tag.isNull() {
                    tempObj.value = nil
                } else if tag.isBoolean() {
                    if let value = contents.first {
                        tempObj.value = value > 0 ? true : false
                    }
                } else if tag.isObjectIdentifier() {
                    // Decode the content as an Object Identifier (OID).
                    tempObj.value = decodeOid(contentData: &contents)
                } else if tag.isInteger() {
                    // Remove leading zero bytes for integers.
                    while contents.first == 0 {
                        contents.remove(at: 0)
                    }
                    tempObj.value = contents
                } else if tag.isString() {
                    // Decode the content as a string using UTF-8 encoding.
                    tempObj.value = String(data: contents, encoding: .utf8)
                } else if tag.isBmpString() {
                    // Decode the content as a BMP string and convert it to Unicode.
                    tempObj.value = String(data: contents, encoding: .unicode)
                } else if tag.isVisibleString() {
                    // Decode the content as a visible string and convert it to ASCII.
                    tempObj.value = String(data: contents, encoding: .ascii)
                } else if tag.isUTCTime() {
                    // Decode the content as a UTC time and parse it using specified date formats.
                    tempObj.value = dateFormatter(contentData: &contents,
                                                  formats: ["yyMMddHHmmssZ", "yyMMddHHmmZ"])
                } else if tag.isGeneralizedTime() {
                    // Decode the content as a generalized time and parse it using a specific date format.
                    tempObj.value = dateFormatter(contentData: &contents, formats: ["yyyyMMddHHmmssZ"])
                } else if tag.isBit() {
                    if !contents.isEmpty {
                        _ = contents.remove(at: 0) // Remove unused bits.
                    }
                    tempObj.value = contents
                } else if tag.isOctect() {
                    do {
                        // Process octet strings with recursive subobject decoding.
                        var subIterator = contents.makeIterator()
                        tempObj.subObjects = try process(iterator: &subIterator)
                    } catch {
                        if let str = String(data: contents, encoding: .utf8) {
                            tempObj.value = str
                        } else {
                            tempObj.value = contents
                        }
                    }
                } else {
                    // Handle other cases by storing the contents as the value.
                    tempObj.value = contents
                }
            } else {
                // Handle non-universal tags by storing the contents as the value.
                let contents = try decodeContents(iterator: &iterator)
                tempObj.rawValue = Data(contents)
                
                if let str = String(data: contents, encoding: .utf8) {
                    tempObj.value = str
                } else {
                    tempObj.value = contents
                }
            }
            
            // Add the processed ASN.1 object to the array.
            decodableObjects.append(tempObj)
        }
        
        return decodableObjects
    }

    
    /// Decodes an ASN.1 Object Identifier (OID) from the provided `contentData` and returns it as a human-readable string.
    ///
    /// - Parameters:
    ///   - contentData: The data containing the encoded OID.
    /// - Returns: A human-readable OID string if decoding is successful, or `nil` if the data is empty or decoding fails.
    static func decodeOid(contentData: inout Data) -> String? {
        // Check if the content data is empty, and return nil in such cases.
        if contentData.isEmpty {
            return nil
        }
        
        // Initialize a string to store the decoded OID.
        var oid: String = ""
        
        // Extract the first byte from the contentData and convert it to an integer.
        let first = Int(contentData.remove(at: 0))
        
        // Calculate the first two components of the OID and append them to the OID string.
        oid.append("\(first / 40).\(first % 40)")
        
        // Initialize a variable to accumulate the value of each portion of the OID.
        var tempValue = 0
        
        // Iterate through the remaining bytes in contentData.
        while !contentData.isEmpty {
            // Extract the next byte (n) from contentData.
            let nextByte = Int(contentData.remove(at: 0))
            
            // Accumulate the value for this portion of the OID.
            tempValue = (tempValue << 7) | (nextByte & 0x7F)
            
            // Check if the most significant bit (bit 7) of the byte is not set (bit 7 = 0).
            if (nextByte & 0x80) == 0 {
                // If the most significant bit is not set, it indicates the end of the current portion.
                // Append the accumulated value to the OID string, separated by a period.
                oid.append(".\(tempValue)")
                // Reset the accumulator for the next portion.
                tempValue = 0
            }
        }
        
        // Return the human-readable OID string.
        return oid
    }

    
    
    /// Responsible for decoding the length of the content in an ASN.1 data stream. ASN.1 uses a variable-length encoding scheme for specifying the length of content, which can be either "short form" or "long form" depending on the value of the first byte.
    ///
    /// - Parameter iterator:Data.Iterator
    /// - Returns: UInt64
    private static func getLength(iterator: inout Data.Iterator) -> UInt64 {
        // The first byte indicates the length of the content.
        let first = iterator.next()
        if first != nil {
            // Checks whether the most significant bit (bit 7) of the first byte is set.
            /// If the most significant bit (bit 7) is set to 1 (i.e., it's greater than or equal to 0x80 in hexadecimal), it signifies that the length is encoded in the "long form." The lower 7 bits of the length byte represent the number of subsequent bytes used to encode the actual length value.
            /// If the most significant bit is set to 0 (i.e., it's less than 0x80), it signifies that the length is encoded in the "short form," and the lower 7 bits of the length byte directly represent the length value.
            if (first! & 0x80) != 0 {
                // Calculates how many octets (bytes) will be used to represent the length.
                let octetsToRead = first! - 0x80
                var data = Data()
                //  Collect the octets, appending each to the data object.
                for _ in 0..<octetsToRead {
                    if let n = iterator.next() {
                        data.append(n)
                    }
                }
                // Attempts to convert the collected octets into a UInt64 value.
                return data.uint64Value ?? 0
            } else {
                // If the most significant bit is not set (short form), directly returns the length as a UInt64 using UInt64(first!).
                return UInt64(first!)
            }
        }
        return 0
    }
    
    /// Responsible for extracting the content of an ASN.1 object from an ASN.1-encoded data stream. It calculates the length of the content, collects the bytes, and returns a Data object containing that content.
    ///
    /// - Parameter iterator:Data.Iterator
    /// - Returns: The sub-object with a matching tag number, or `nil` if not found.
    private static func decodeContents(iterator: inout Data.Iterator) throws -> Data {
        let contentLength = getLength(iterator: &iterator)
        
        // If the length is beyond range max value Int can hold of, it returns an empty Data object, likely to indicate that there's an issue with the data.
        if  contentLength < Int.max {
            // Empty array to store the bytes of the content.
            var byteArray: [UInt8] = []
            /// The subsequent for loop is used to iterate over the expected number of bytes indicated by len. Inside the loop:
            /// - if let n = iterator.next(): It checks if there's a next value in the iterator.
            /// - byteArray.append(n): If there is a next value, it appends it to the byteArray. This effectively collects the bytes of the content.
            for _ in 0..<Int(contentLength) {
                if let n = iterator.next() {
                    byteArray.append(n)
                } else {
                    throw DecoderError.BufferBoundError
                }
            }
            return Data(byteArray)
        } else {
            return Data()
        }
    }
    /// Attempts to parse a date string from the given `contentData` using a list of date `formats`.
    ///
    /// - Parameters:
    ///   - contentData: The data containing the date string to be parsed.
    ///   - formats: An array of date formats to use for parsing.
    /// - Returns: A `Date` object if parsing is successful, or `nil` if parsing fails for all formats.
    private static func dateFormatter(contentData: inout Data, formats: [String]) -> Date? {
        // Convert the content data to a UTF-8 string.
        guard let str = String(data: contentData, encoding: .utf8) else { return nil }
        // Attempt to parse the string using the provided date formats.
        for format in formats {
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.dateFormat = format
            if let dt = fmt.date(from: str) {
                return dt
            }
        }
        
        // If parsing fails for all formats, return nil.
        return nil
    }
}
