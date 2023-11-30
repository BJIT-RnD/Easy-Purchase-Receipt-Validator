/**
 File Name: `AppleContainer+Extensions.swift`

 Description: This file extends the functionality of the `AppleContainer` class by adding additional enums and methods related to Apple Receipt processing and date parsing.

 ## Enumerations

 1. `receiptFields`: Enumerates receipt-related fields with associated raw values representing their tag numbers.
 2. `purchaseFields`: Enumerates in-app purchase-related fields with associated raw values representing their tag numbers.
 */

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
        case inAppPurchase = 17
    }
    // Reference and tag taken from: https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ReceiptFields.html

    enum purchaseFields: UInt64 {
        case quantities = 1701
        case productIdentifier = 1702
        case transactionId = 1703
        case originalTransactionId = 1705
        case purchaseDate = 1704
        case originalPurchaseDate = 1706
        case expireDate = 1708
        case isIntroPeriod = 1719
        case cancellationDate = 1712
        case webOrderLine = 1711
    }

    // MARK: - Date Processing
    
    /// Processes a date string and returns a Date object if parsing is successful.
    ///
    /// - Parameter dateString: The date string to process.
    /// - Returns: A Date object if parsing is successful, otherwise nil.
    private func processDate(_ dateString: String) -> Date? {
        return ReceiptDateParser.parseDate(from: dateString)
    }
    
    // MARK: - Apple Receipt Processing
    
    /// Processes the Apple Receipt and extracts relevant information into a PayloadData object.
    ///
    /// - Returns: A PayloadData object containing information from the Apple Receipt, or nil if the processing fails.
    public func AppleReceipt() throws -> InAppReceiptValidatorProtocol {
        // Find the relevant block within the coreBlock structure that contains the Apple Receipt data.
        guard let receiptBlock = coreBlock.findASN1Object(of: .pkcs7data)?.parent?.childs?.last?.childASN1Object(at: 0)?.childASN1Object(at: 0) else {
            throw ReceiptError.invalidReceiptBlock
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

            case receiptFields.inAppPurchase.rawValue:
                let subItems = field.childASN1Object(at: 2)?.childs?.first?.childs ?? []
                if payloadData.inAppPurchasesReceipt == nil {
                    payloadData.inAppPurchasesReceipt = []
                }
                payloadData.inAppPurchasesReceipt?.append(inAppPurchase(subItems))

            default:
                break
            }
        }
        // Return the Interface object containing the extracted information.
        return InAppReceiptValidator(payloadData)
    }

    /// Processes a list of ASN.1 sub-items representing in-app purchase information and extracts relevant details into a `PurchaseData` object.
    ///
    /// - Parameter subItems: The list of ASN.1 sub-items containing in-app purchase data.
    /// - Returns: A populated `PurchaseData` object with extracted in-app purchase information.
    ///
    /// Each sub-item in the provided list corresponds to a specific field in the in-app purchase data structure. The function iterates through the sub-items, retrieves field types and values, and updates the corresponding properties in the `PurchaseData` structure.
    /// - Note: This function is designed to be used within the context of processing Apple Receipt data.
    private func inAppPurchase(_ subItems: [ASN1Object]) -> PurchaseData {
        // Initialize the PurchaseData structure to hold in-app purchase information.
        var inAppPurchaseData = PurchaseData()

        // Iterate through each sub-item in the provided list.
        for subItem in subItems {
            // Retrieve the field type from the sub-item, considering it as an ASN.1 structure.
            let fieldType = (subItem.childASN1Object(at: 0)?.value as? Data)?.uint64Value ?? 0

            // Extract the field value from the sub-item structure.
            let fieldValue = subItem.childASN1Object(at: 2)?.childs?.first?.value

            // Switch statement to process and update the PurchaseData properties based on the field type.
            switch fieldType {
                // Quantity of the in-app purchase.
                case purchaseFields.quantities.rawValue:
                    inAppPurchaseData.quantities = (fieldValue as? Data)?.uint64Value

                // Product identifier of the in-app purchase.
                case purchaseFields.productIdentifier.rawValue:
                    inAppPurchaseData.productIdentifier = fieldValue as? String

                // Transaction ID of the in-app purchase.
                case purchaseFields.transactionId.rawValue:
                    inAppPurchaseData.transactionId = fieldValue as? String

                // Original transaction ID of the in-app purchase.
                case purchaseFields.originalTransactionId.rawValue:
                    inAppPurchaseData.originalTransactionId = fieldValue as? String

                // Purchase date of the in-app purchase.
                case purchaseFields.purchaseDate.rawValue:
                    if let fieldValueString = fieldValue as? String {
                        inAppPurchaseData.purchaseDate = processDate(fieldValueString)
                    }

                // Original purchase date of the in-app purchase.
                case purchaseFields.originalPurchaseDate.rawValue:
                    if let fieldValueString = fieldValue as? String {
                        inAppPurchaseData.originalPurchaseDate = processDate(fieldValueString)
                    }

                // Expiration date of the in-app purchase.
                case purchaseFields.expireDate.rawValue:
                    if let fieldValueString = fieldValue as? String {
                        inAppPurchaseData.expiresDate = processDate(fieldValueString)
                    }

                // Indicates if the in-app purchase is in an introductory offer period.
                case purchaseFields.isIntroPeriod.rawValue:
                    inAppPurchaseData.isInIntroOfferPeriod = (fieldValue as? Data)?.uint64Value

                // Cancellation date of the in-app purchase.
                case purchaseFields.cancellationDate.rawValue:
                    if let fieldValueString = fieldValue as? String {
                        inAppPurchaseData.cancellationDate = processDate(fieldValueString)
                    }

                // Web order line item ID of the in-app purchase.
                case purchaseFields.webOrderLine.rawValue:
                    inAppPurchaseData.webOrderLineItemId = (fieldValue as? Data)?.uint64Value

                // Default case for unhandled field types.
                default:
                    break
            }
        }

        // Return the populated PurchaseData object containing in-app purchase information.
        return inAppPurchaseData
    }
}
