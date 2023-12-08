/**
 File Name: `AppleContainer.swift`

 Description: This file contains the implementation of the `AppleContainer` class, which is responsible for managing Apple Container data and parsing it.
 */
import Foundation

protocol AppleContainerProtocol {
    var coreBlock: ASN1Object { get }
    var algorithm: String? { get }
    var detectAlgorithmName: String? { get }
    func AppleReceipt() throws -> InAppReceiptValidatorProtocol
}
/**
 The `AppleContainer` class is responsible for handling Apple Container data. It extracts information from the ASN.1 structure in the Apple Container.

 - Parameters:
     - `data`: The input data containing the Apple Container information.

 - Throws:
     - `ContainerError.invalid`: Indicates that the Apple Container is invalid.
     - `ContainerError.parsingIssue`: Indicates an issue with parsing the Apple Container data.
 */
public final class AppleContainer: AppleContainerProtocol {
    // Primary block containing the PKCS7 structure.
    public let coreBlock: ASN1Object
    /**
     Initializes an `AppleContainer` instance with the provided data.
     - initialBlock represents the top-level ASN.1 object in the hierarchy, which corresponds to the outermost structure of the PKCS7 data.
     - initialBlock.sub(1) accesses the first subelement of firstBlock. In the context of PKCS7, this is often the part that contains the actual signed data.
     - initialBlock.sub(1)?.sub(0) further accesses the first subelement of the first subelement, which is typically where the actual data or content to be signed is located. This is often the innermost layer in the PKCS7 structure.
     
     
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
            throw AppleContainerErrors.parsingIssue
        }
        self.coreBlock = coreBlock
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
    private func detectAlgorithm(block: ASN1Object) -> Any? {
        var calculatedBlock = block
        // Check if there are children and if the array is not empty
        while calculatedBlock.childs != nil && !calculatedBlock.childs!.isEmpty {
            // Update calculatedBlock to be the first child
            calculatedBlock = (calculatedBlock.childs?.first)!
        }
        // Return the value of the leaf element
        return calculatedBlock.value
    }
    
    
    /**
     Returns the name of the detected algorithm.
     
     - Returns: The name of the algorithm, or the algorithm string if the name is not found.
     */
    internal var detectAlgorithmName: String? {
        return OID.description(of: algorithm ?? "") ?? algorithm
    }
}

// MARK: Signature
extension AppleContainer {
    func getSignatures() throws -> [SignatureInfo] {
        if let signerInfos = coreBlock.childASN1Object(at: 4) {
            return SignatureDecoder.retriveSignature(from: signerInfos)
        } else {
            throw AppleContainerErrors.signatureNotAvailable
        }
    }
}

// MARK: Certificate
extension AppleContainer {
    func getAllCertificate() -> [CertificateParser] {
        let certificates = coreBlock.childASN1Object(at: 3)?.childs?.compactMap ({ asn1Object in
            try? CertificateParser(asn1: asn1Object)
        }) ?? []
        return certificates
    }
    /**
     Return `CertificateParser` object which is responsable to parse the 1st certificate from 3 existing certificate
     */
    func getOnlySignatureValidationCertificate() -> CertificateParser? {
        return coreBlock.childASN1Object(at: 3)?.childs?.first.map { try? CertificateParser(asn1: $0) } ?? nil
    }
}
