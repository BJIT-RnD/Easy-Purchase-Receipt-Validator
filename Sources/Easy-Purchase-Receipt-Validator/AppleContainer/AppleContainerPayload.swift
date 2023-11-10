//
//  File.swift
//  
//
//  Created by BJIT on 10/11/23.
//

import Foundation
extension AppleContainer {
    
    // MARK: - Enum for Receipt Fields
    
    enum receiptFields: UInt64 {
        case bundleIdentifier = 2
        case bundleVersion = 3
        case opaqueValue = 4
        case sha1 = 5
        case appVersion = 19
        case createdDate = 12
        case expireDate = 21
    }
    
    // MARK: - Date Processing
    
    /// Processes a date string and returns a Date object if parsing is successful.
    ///
    /// - Parameter dateString: The date string to process.
    /// - Returns: A Date object if parsing is successful, otherwise nil.
    func processDate(_ dateString: String) -> Date? {
        return ReceiptDateParser.parseDate(from: dateString)
    }
    
    // MARK: - Apple Receipt Processing
    
    /// Processes the Apple Receipt and extracts relevant information into a PayloadData object.
    ///
    /// - Returns: A PayloadData object containing information from the Apple Receipt, or nil if the processing fails.
    public func AppleReceipt() -> PayloadData? {
        // Find the relevant block within the coreBlock structure that contains the Apple Receipt data.
        guard let receiptBlock = coreBlock.findASN1Object(of: .pkcs7data)?.parent?.childs?.last?.childASN1Object(at: 0)?.childASN1Object(at: 0) else {
            return nil
        }
        
        // Create an empty PayloadData object to store the extracted information.
        var payloadData = PayloadData()
        
        // Iterate through each field in the receiptBlock and extract information based on the field type.
        for field in receiptBlock.childs ?? [] {
            // Extract the field type and field value string from the current field.
            let fieldType = (field.childASN1Object(at: 0)?.value as? Data)?.uint64Value ?? 0
            let fieldValueString = field.childASN1Object(at: 2)?.asString
            
            // Switch based on the field type and update the corresponding property in the PayloadData object.
            // tag ref https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html#//apple_ref/doc/uid/TP40010573-CH106-SW1
            switch fieldType {
            case receiptFields.bundleIdentifier.rawValue:
                payloadData.bundleIdentifier = fieldValueString
                payloadData.bundleIdentifierData = field.childASN1Object(at: 2)?.rawValue

            case receiptFields.bundleVersion.rawValue:
                payloadData.bundleVersion = fieldValueString

            case receiptFields.opaqueValue.rawValue:
                payloadData.opaqueValue = field.childASN1Object(at: 2)?.rawValue

            case receiptFields.sha1.rawValue:
                payloadData.sha1Hash = field.childASN1Object(at: 2)?.rawValue

            case receiptFields.appVersion.rawValue:
                payloadData.originalApplicationVersion = fieldValueString

            case receiptFields.createdDate.rawValue:
                // Process and store receipt creation date information.
                guard let fieldValueString = fieldValueString else { continue }
                payloadData.receiptCreationDateString = fieldValueString
                payloadData.receiptCreationDate = processDate(fieldValueString)

            case receiptFields.expireDate.rawValue:
                // Process and store receipt expiration date information.
                guard let fieldValueString = fieldValueString else { continue }
                payloadData.receiptExpirationDateString = fieldValueString
                payloadData.receiptExpirationDate = processDate(fieldValueString)

            default:
                break
            }
        }
        
        // Return the PayloadData object containing the extracted information.
        return payloadData
    }
}

