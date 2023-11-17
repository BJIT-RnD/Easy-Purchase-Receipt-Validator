/**
 File Name: `PurchaseData.swift`

 Description: This file defines the `PurchaseData` struct, representing information related to an in-app purchase.

 ## Properties

 1. `quantities`: Quantity of the in-app purchase.
 2. `productIdentifier`: Product identifier of the in-app purchase.
 3. `transactionId`: Transaction ID of the in-app purchase.
 4. `originalTransactionId`: Original transaction ID of the in-app purchase.
 5. `purchaseDate`: Purchase date of the in-app purchase.
 6. `originalPurchaseDate`: Original purchase date of the in-app purchase.
 7. `expiresDate`: Expiration date of the in-app purchase.
 8. `isInIntroOfferPeriod`: Indicates if the in-app purchase is in an introductory offer period.
 9. `cancellationDate`: Cancellation date of the in-app purchase.
 10. `webOrderLineItemId`: Web order line item ID of the in-app purchase.

 - Note: This struct is designed to represent in-app purchase information extracted from an Apple Receipt during processing.
 */
import Foundation
public struct PurchaseData {
    public var quantities: UInt64?
    public var productIdentifier: String?
    public var transactionId: String?
    public var originalTransactionId: String?
    public var purchaseDate: Date?
    public var originalPurchaseDate: Date?
    public var expiresDate: Date?
    public var isInIntroOfferPeriod: UInt64?
    public var cancellationDate: Date?
    public var webOrderLineItemId: UInt64?
}
