//
//  File.swift
//  
//
//  Created by BJIT on 9/11/23.
//

import Foundation
import XCTest
@testable import Easy_Purchase_Receipt_Validator

class InAppReceiptTests: XCTestCase {
    var receiptInfo: InAppReceipt?

    override func setUp() {
        super.setUp()
        // Setting up the test environment
        receiptInfo = InAppReceipt()
    }

    override func tearDown() {
        super.tearDown()
        // Tear down the test environment

        // Release the object to free up resources
        receiptInfo = nil
    }

    /// Test case to validate the extraction of bundle identifier from InAppReceipt payload.
    func testBundleIdentifier() {
        // When
        let bundleIdentifier = receiptInfo?.bundleIdentifier

        // Then
        XCTAssertEqual(bundleIdentifier, "com.example.app", "Bundle identifier should match the expected value.")
    }

    /// Test case to validate the extraction of app version from InAppReceipt payload.
    func testAppVersion() {
        // When
        let appVersion = receiptInfo?.appVersion

        // Then
        XCTAssertEqual(appVersion, "1.0", "App version should match the expected value.")
    }

    /// Test case to validate the extraction of original app version from InAppReceipt payload.
    func testOriginalAppVersion() {
        // When
        let originalAppVersion = receiptInfo?.originalAppVersion

        // Then
        XCTAssertEqual(originalAppVersion, "1.0", "Original app version should match the expected value.")
    }
}
