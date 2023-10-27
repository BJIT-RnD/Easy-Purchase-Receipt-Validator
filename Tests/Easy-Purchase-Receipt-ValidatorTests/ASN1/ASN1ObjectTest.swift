/**
 File Name: ASN1ObjectTest.swift
 
 Description: This file contains the implementation of the `ASN1ObjectTest` class, which is responsible for testing `ASN1Object` class.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

import XCTest
@testable import Easy_Purchase_Receipt_Validator

final class ASN1ObjectTest: XCTestCase {
    private var sut: ASN1Object!
    override func setUp() {
        super.setUp()
        let obj: [UInt8] = [0x30, 0x08, 0x02, 0x01, 0x42, 0x04, 0x03, 0x61, 0x62, 0x63]
        let data = Data(obj)
        var iterator = data.makeIterator()
        self.sut = ASN1Object()
    }
    
    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }
    
    func test_childASN1Object_Given_ValidIndex_Expect_ASN1Object() {
        //
    }
    
    func test_childASN1Object_Given_InvalidIndex_Expect_Nill() {
        //
    }
    
    
    // MARK: - numberOfChilds. Remain corrupted ASN1Object
    func test_numberOfChilds_Given_ASN1ObjectWith2Child_Expect_2_Child() {
        //
    }
    
    func test_numberOfChilds_Given_ASN1ObjectWith0Child_Expect_0_Child() {
        //
    }
    
    // MARK: - findASN1Object
    func test_findASN1Object_Given_OIDWhichIsAvailable_Expect_ASN1Object() {
        //
    }
    
    func test_findASN1Object_Given_OIDWhichNotAvailable_Expect_Nill() {
        //
    }
}
