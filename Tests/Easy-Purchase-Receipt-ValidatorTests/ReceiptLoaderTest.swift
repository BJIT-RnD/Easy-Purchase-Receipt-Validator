//
//  ReceiptLoaderTest.swift
//

import XCTest
@testable import Easy_Purchase_Receipt_Validator

final class ReceiptLoaderTest: XCTestCase {
    var receiptLoader: ReceiptLoader?
    override func setUp() {
        super.setUp()
        receiptLoader = ReceiptLoader()
    }
    override func tearDown() {
        super.tearDown()
        receiptLoader = nil
    }
    func test_getReceipt_whenInvalidUrlGiven_shouldReturnInvalidURLError() {
        let url = URL(string: "")
        receiptLoader?.getReceipt(url) { data, error   in
            XCTAssertEqual(error, ReceiptError.invalidURL, "Error expected to be .invalidURL but found \(String(describing: error))")
            XCTAssertNil(data, "Receipt data expected to be nil but found \(String(describing: data))")
        }
    }
    func test_getReceipt_whenIncorrectValidURLGiven_shouldReturnErrorAsFileNotFound() {
        let url = URL(string: "receipt/fileNotFountURL")
        receiptLoader?.getReceipt(url) { data, error in
            XCTAssertEqual(error, ReceiptError.fileNotFound, "Error expected to be .fileNotFound but found \(String(describing: error))")
            XCTAssertNil(data, "Receipt data expected to be nil but found \(String(describing: data))")
        }
    }
}
