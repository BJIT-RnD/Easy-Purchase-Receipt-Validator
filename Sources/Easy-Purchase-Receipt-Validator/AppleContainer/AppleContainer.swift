/**
 File Name: `AppleContainer.swift`

 Description: This file contains the implementation of the `AppleContainer` class, which is responsible for managing Apple Container data and parsing it.
 */
import Foundation

/**
 The `AppleContainer` class is responsible for handling Apple Container data. It extracts information from the ASN.1 structure in the Apple Container.

 - Parameters:
     - `data`: The input data containing the Apple Container information.

 - Throws:
     - `ContainerError.invalid`: Indicates that the Apple Container is invalid.
     - `ContainerError.parsingIssue`: Indicates an issue with parsing the Apple Container data.
 */
class AppleContainer {
    
    //Primary block containing the PKCS7 structure.
    public let coreBlock: ASN1Object

    /**
     Initializes an `AppleContainer` instance with the provided data.

     - Parameters:
         - `data`: The input data containing Apple Container information.

     - Throws:
         - `ContainerError.parsingIssue`: Indicates an issue with parsing the Apple Container data.
     */
    public init(data: Data) throws {
        let decoder = ASN1Decoder()
        let decodedData = try decoder.decode(data: data)

        /*
         - initialBlock represents the top-level ASN.1 object in the hierarchy, which corresponds to the outermost structure of the PKCS7 data.
         - initialBlock.sub(1) accesses the first subelement of firstBlock. In the context of PKCS7, this is often the part that contains the actual signed data.
         - initialBlock.sub(1)?.sub(0) further accesses the first subelement of the first subelement, which is typically where the actual data or content to be signed is located. This is often the innermost layer in the PKCS7 structure.
         */
        guard let initialBlock = decodedData.first,
              let coreBlock = initialBlock.childASN1Object(at: 1)?.childASN1Object(at: 0) else {
            throw ContainerError.parsingIssue
        }
        self.coreBlock = coreBlock
    }
    
    // This property still responsible for extracting the data content from a PKCS7 structure,
    public var data: Data? {
        if let dataBlock = findDataBlock(coreBlock) {
            return extractData(from: dataBlock)
        }
        return nil
    }

    /**
     Returns the algorithm used in the Apple Container. the algorithm is a critical part of the digital signature process in PKCS7, and it helps verify the integrity and authenticity of the data.
     The result of firstLeafValue is cast to a String, and this value is returned as the digestAlgorithm.
     - Returns: The algorithm used, or `nil` if not present.
     */
    public var algorithm: String? {
        // if let block = mainBlock.sub(1) checks if there is a subelement at index 1 within the mainBlock. In the context of PKCS7, this subelement often corresponds to the part that contains the signed data and associated information.
        if let block = coreBlock.childASN1Object(at: 1) {
            // The detectAlgorithm function is to extract the value of the first leaf element in the ASN.1 object hierarchy. In this case, it's expected that the first leaf element within block represents the digest algorithm used in the PKCS7 structure.
            return detectAlgorithm(block: block) as? String
        }
        return nil
    }

    /**
     The detectAlgorithm function is a recursive function used to find the first leaf element in a hierarchy of ASN.1 objects and return its value. In ASN.1 encoding, a leaf element is an element that doesn't have any nested sub-elements. The purpose of this function is to navigate through the hierarchy of ASN.1 objects to find the value stored in the first leaf element, which is typically where the desired information is located.

     - Parameters:
         - `block`: The ASN.1 block to analyze.

     - Returns: The detected algorithm, or `nil` if not found.
     */
    public func detectAlgorithm(block: ASN1Object) -> Any? {
        if let child = block.childs?.first {
            return detectAlgorithm(block: child)
        }
        // When a leaf element is found, meaning there are no more nested sub-elements, the function returns the value of that leaf element using block.value.
        return block.value
    }

    /**
     Returns the name of the detected algorithm.

     - Returns: The name of the algorithm, or the algorithm string if the name is not found.
     */
    public var detectAlgorithmName: String? {
        return OID.description(of: algorithm ?? "") ?? algorithm
    }

    /**
     Helper function that locates the data block with the specified Object Identifier (OID), in this case, .pkcs7data. It does this by calling the findASN1Object(of:) function to find the block with the specified OID, then accesses its parent, and finally retrieves the last child block. This is where the data content is expected to be.

     - Parameters:
        - `coreBlock`: The ASN.1 block to analyze.

     - Returns: The detected algorithm, or `nil` if not found.
     */
    private func findDataBlock(_ coreBlock: ASN1Object) -> ASN1Object? {
        // successfully locates the data block, it returns this block.
        return coreBlock.findASN1Object(of: .pkcs7data)?.parent?.childs?.last
    }

    /**
     This function is responsible for extracting the data content from the data block.
     - The function then iterates through the sub-elements of the data block (dataBlock). For each sub-element, it appends its value using the appendValue(_:) function.
     - It also iterates through the sub-elements of the sub-element to ensure all levels of nesting are explored and the data is properly extracted and appended.
     - Finally, after accumulating the potential data content into the out variable, the code checks if the out variable has data (i.e., it's not empty).

     - Parameters:
        - `dataBlock`: The ASN.1 block to analyze.

     - Returns: If it has data, it returns the out variable as a Data object. If not, it returns nil.
     */
    private func extractData(from dataBlock: ASN1Object) -> Data? {
        // An empty Data object named out to accumulate the data content.
        var out = Data()

        // Helper function to append data to the 'out' data variable
        func appendValue(_ value: Any?) {
            if let data = value as? Data {
                out.append(data)
            } else if let rawValue = value as? Data {
                out.append(rawValue)
            }
        }

        // Iterate through the sub-elements of the data block
        for child in dataBlock.childs ?? [] {
            // Append the value from the current sub-element
            appendValue(child.value)

            // Iterate through the sub-elements of the sub-element
            for child2 in child.childs ?? [] {
                // Append the raw value from the sub-element
                appendValue(child2.rawValue)
            }
        }

        // Check if there's data in the 'out' variable and return it, or return nil
        return !out.isEmpty ? out : nil
    }
}

extension AppleContainer {
    
}
