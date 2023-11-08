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

        guard let initialBlock = decodedData.first,
              let coreBlock = initialBlock.childASN1Object(at: 1)?.childASN1Object(at: 0) else {
            throw ContainerError.parsingIssue
        }
        self.coreBlock = coreBlock
    }

    /**
     Returns the algorithm used in the Apple Container.

     - Returns: The algorithm used, or `nil` if not present.
     */
    public var algorithm: String? {
        if let block = coreBlock.childASN1Object(at: 1) {
            return detectAlgorithm(block: block) as? String
        }
        return nil
    }

    /**
     Detects the algorithm used in the Apple Container data.

     - Parameters:
         - `block`: The ASN.1 block to analyze.

     - Returns: The detected algorithm, or `nil` if not found.
     */
    public func detectAlgorithm(block: ASN1Object) -> Any? {
        if let child = block.childs?.first {
            return detectAlgorithm(block: child)
        }
        return block.value
    }

    /**
     Returns the name of the detected algorithm.

     - Returns: The name of the algorithm, or the algorithm string if the name is not found.
     */
    public var detectAlgorithmName: String? {
        return OID.description(of: algorithm ?? "") ?? algorithm
    }

    // Private function to find the data block with the specified OID
    private func findDataBlock(_ coreBlock: ASN1Object) -> ASN1Object? {
        return coreBlock.findASN1Object(of: .pkcs7data)?.parent?.childs?.last
    }

    // Private function to extract and append data from the data block
    private func extractData(from dataBlock: ASN1Object) -> Data? {
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

/**
 Enumeration `ContainerError` is used to represent errors that can occur during Apple Container processing.
 */
enum ContainerError: Error {
    case invalid
    case parsingIssue
}
