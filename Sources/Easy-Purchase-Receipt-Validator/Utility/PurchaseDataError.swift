//
//  PurchaseDataError.swift
// Handling errors regarding PurchaseData
//

import Foundation

public enum PurchaseDataError: Error {
    case notAutoRenewableProduct
    case productIsCancelled
    case productNotPurchased
    case expireDateNotAvailable
}
