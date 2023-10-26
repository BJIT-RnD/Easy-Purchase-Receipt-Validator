/**
 File Name: ASN1IdentifierTest.swift
 
 Description: This file contains the implementation of the `ASN1IdentifierTest` class, which is responsible for testing `ASN1Identifier` class.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

import XCTest
@testable import Easy_Purchase_Receipt_Validator

final class ASN1IdentifierTest: XCTestCase {
    private var sut: ASN1Identifier!
    override func setUp() {
        super.setUp()
        self.sut = ASN1Identifier(rawValue: 0x30)
    }
    
    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }
    
    func test_typeClass_Given_Universal_Expect_Universal() {
        self.sut.rawValue = 0x00
        let typeClass = self.sut.typeClass()
        XCTAssertEqual(typeClass, .universal, "Expected to be \(ASN1Identifier.Class.universal) but get \(typeClass).")
    }
    
    func test_typeClass_Given_contextSpecific_Expect_contextSpecific() {
        self.sut.rawValue = 0xA1
        let typeClass = self.sut.typeClass()
        XCTAssertEqual(typeClass, ASN1Identifier.Class.contextSpecific, "Expected to be \(ASN1Identifier.Class.contextSpecific) but get \(typeClass).")
    }
    
    func test_isPrimitive_Given_Primitive_Expect_True() {
        self.sut.rawValue = 0x0C
        let result = self.sut.isPrimitive()
        XCTAssertTrue(result, "Expect true but get \(result)")
    }
    
    func test_isPrimitive_Given_Constructed_Expect_False() {
        self.sut.rawValue = 0x30
        let result = self.sut.isPrimitive()
        XCTAssertFalse(result, "Expect false but get \(result)")
    }
    
    func test_isConstructed_Given_Primitive_Expect_False() {
        self.sut.rawValue = 0x0C
        let result = self.sut.isConstructed()
        XCTAssertFalse(result, "Expect false but get \(result)")
    }
    
    func test_isConstructed_Given_Constructed_Expect_True() {
        self.sut.rawValue = 0x30
        let result = self.sut.isConstructed()
        XCTAssertTrue(result, "Expect true but get \(result)")
    }
    
    func test_tagNumber_Given_booleanTag_Expect_booleanTag() {
        self.sut.rawValue = 0x01
        let result = self.sut.tagNumber()
        XCTAssertEqual(result, ASN1Identifier.TagNumber.boolean, "Expect \(ASN1Identifier.TagNumber.boolean) but get \(result)")
    }
    
    func test_tagNumber_Given_sequenceTag_Expect_sequenceTag() {
        let result = self.sut.tagNumber()
        XCTAssertEqual(result, ASN1Identifier.TagNumber.sequence, "Expect \(ASN1Identifier.TagNumber.sequence) but get \(result)")
    }
}
