//
//  PurchaseDataTest.swift
//  
//
//  Created by BJIT on 29/11/23.
//

import XCTest
@testable import Easy_Purchase_Receipt_Validator

final class PurchaseDataTest: XCTestCase {
    // sample receipt
    // swiftlint:disable:next line_length
    let testReceipt = "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"
    
    /// Test case to validate the count of all auto-renew products from InAppReceipt payload.
    func test_InAppReceiptValidator_whenValidReceiptGiven_allAutoRenewCount_ShouldReturnTwenty() {
        // Arrange
        guard let data = Data(base64Encoded: testReceipt) else {
            return
        }
        let appleContainer = try? AppleContainer(data: data)
        let receiptInfo = try? appleContainer?.AppleReceipt()
        // When
        let totalAutoRenewPurchase = receiptInfo?.allAutoRenewables
        // Then
        XCTAssertEqual(totalAutoRenewPurchase?.count, 20, "There should be total 13 auto-renew products in the test receipt.")
    }
    
    /// Test case to validate the count of active auto-renew products from InAppReceipt payload.
    func test_InAppReceiptValidator_whenValidReceiptGiven_activeAutoRenewCount_shouldReturnZero() {
        // Arrange
        guard let data = Data(base64Encoded: testReceipt) else {
            return
        }
        let appleContainer = try? AppleContainer(data: data)
        let receiptInfo = try? appleContainer?.AppleReceipt()
        // When
        let totalActivePurchase = receiptInfo?.activeAutoRenewables
        // Then
        XCTAssertEqual(totalActivePurchase?.count, 0, "There should be total 0 active auto-renew products in the test receipt.")
    }
    
    func test_PurchaseData_whenCancelDateExist_isActiveAutoRenewableShouldReturnFalse() {
        // Arrange
        let product = PurchaseData(quantities: 1, productIdentifier: "abcd", transactionId: "1234", originalTransactionId: "1234", purchaseDate: Date(), originalPurchaseDate: Date(), expiresDate: Date(), isInIntroOfferPeriod: 1, webOrderLineItemId: 1 )
        // Act
        let activeStatus = product.isActiveAutoRenewable()
        // Assert
        XCTAssertFalse(activeStatus)
    }
    
    func test_PurchaseData_whenExpireDateNotExist_isActiveAutoRenewableShouldReturnFalse() {
        // Arrange
        let product = PurchaseData(quantities: 1, productIdentifier: "abcd", transactionId: "1234", originalTransactionId: "1234", purchaseDate: Date(), originalPurchaseDate: Date(), isInIntroOfferPeriod: 1, webOrderLineItemId: 1 )
        // Act
        let activeStatus = product.isActiveAutoRenewable()
        // Assert
        XCTAssertFalse(activeStatus)
    }
    
    func test_PurchaseData_whenPurchaseDateNotExist_isActiveAutoRenewableShouldReturnFalse() {
        // Arrange
        let product = PurchaseData(quantities: 1, productIdentifier: "abcd", transactionId: "1234", originalTransactionId: "1234", originalPurchaseDate: Date(), expiresDate: Date(), isInIntroOfferPeriod: 1, webOrderLineItemId: 1 )
        // Act
        let activeStatus = product.isActiveAutoRenewable()
        // Assert
        XCTAssertFalse(activeStatus)
    }
    func test_PurchaseData_whenProductIsActive_isActiveAutoRenewableShouldReturnTrue() {
        // Arrange
        let product = PurchaseData(quantities: 1, productIdentifier: "abcd", transactionId: "1234", originalTransactionId: "1234", purchaseDate: Date(), originalPurchaseDate: Date(), expiresDate: Date() + 10, isInIntroOfferPeriod: 1, webOrderLineItemId: 1 )
        // Act
        let activeStatus = product.isActiveAutoRenewable()
        // Assert
        XCTAssertTrue(activeStatus)
    }
    func test_PurchaseData_whenProductHasExpireDate_isAutoRenewProductShouldReturnTrue() {
        // Arrange
        let product = PurchaseData(quantities: 1, productIdentifier: "abcd", transactionId: "1234", originalTransactionId: "1234", purchaseDate: Date(), originalPurchaseDate: Date(), expiresDate: Date() + 10, isInIntroOfferPeriod: 1, webOrderLineItemId: 1 )
        // Act
        let activeStatus = product.isAutoRenewProduct
        // Assert
        XCTAssertTrue(activeStatus)
    }
}
