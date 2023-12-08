/**
 File Name: `ASN1IDecoderTest.swift`
 
 Description: This file contains the implementation of the `ASN1IDecoder` class,
 which is responsible for decoding or parssing `ASN1Object`.
 
 Author: Md. Rejaul Hasan
 
 © 2023 BJIT. All rights reserved.
 */

import XCTest
@testable import Easy_Purchase_Receipt_Validator

final class ASN1IDecoderTest: XCTestCase {
    var sut: ASN1Decoder!
    var totalASN1ObjInUInt8Form = [UInt8]()
    override func setUp() {
        super.setUp()
        self.sut = ASN1Decoder()
        self.totalASN1ObjInUInt8Form = [UInt8]()
    }
    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }
    // MARK: GetContentLength
    func test_getContentLength_GivenCorrectLengthByte_ExpectNotThrowingAnyError() {
        var iterator = initialSetup(with: [0x08, 0x02, 0x01, 0x42, 0x04, 0x03, 0x61, 0x62, 0x63])
         
        XCTAssertNoThrow(try sut.getContentLength(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form), "Expect not throw any error but it throw and error")
    }
    func test_getContentLength_GivenLengthAs8_Expect_8() {
        var iterator = initialSetup(with: [0x08, 0x02, 0x01, 0x42, 0x04, 0x03, 0x61, 0x62, 0x63])
         
        do {
            let asn1Length = try sut.getContentLength(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
            XCTAssertEqual(Int(asn1Length), 8, "Expected 8 but get \(Int(asn1Length))")
        } catch {
            XCTFail("An error occure \(error)")
        }
    }
    func test_getContentLength_Given7ByteLongLength_Expect_564333000221026() {
        var iterator = initialSetup(with: [0x87, 0x02, 0x01, 0x42, 0x04, 0x03, 0x61, 0x62, 0x63])
         
        let asn1Length = try? sut.getContentLength(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
        XCTAssertNotNil(asn1Length, "Expected not nil but get nil")
        let finalvalue = Int(asn1Length!)
        XCTAssertEqual(finalvalue, 564333000221026, "Expected 564333000221026 but get \(finalvalue)")
    }
    func test_getContentLength_GivenCorruptedLengthdata_Expect_ASN1ErrorLengthEncodingError() {
        var iterator = initialSetup(with: [0x87, 0x02, 0x01])
         
        do {
            let length = try sut.getContentLength(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
            XCTFail("Expected error ASN1Error.lengthEncodingError, but got length: \(length)")
        } catch {
            XCTAssertTrue(error is ASN1Error, "Expected ASN1Error to be thrown.")
            XCTAssertEqual(error as? ASN1Error, ASN1Error.lengthEncodingError, "Expected error ASN1Error.lengthEncodingError.")
        }
    }
    func test_getContentLength_GivenEmpty_Expect_0() {
        var iterator = initialSetup(with: [])
         
        do {
            let length = try sut.getContentLength(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
            XCTAssertEqual(length, 0, "Expected length is 0 but get \(length)")
        } catch {
            XCTFail("Some Error occure \(error)")
        }
    }
    // MARK: loadChildContent
    func test_loadChildContent_Given_CorrectIterator_Expect_NotThrowAnyError() {
        var iterator = initialSetup(with: [0x04, 0x02, 0x01, 0x04, 0x12])
         
        XCTAssertNoThrow(try sut.loadChildContent(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form))
    }
    func test_loadChildContent_Given_IncorrectIterator_Expect_OutOfBufferError() {
        var iterator = initialSetup(with: [0x04, 0x02, 0x01])
         
        do {
            _ = try sut.loadChildContent(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
        } catch {
            XCTAssertTrue(error is ASN1Error, "Expected ASN1Error to be thrown.")
            XCTAssertEqual(error as? ASN1Error, ASN1Error.outOfBuffer, "Expected error ASN1Error.outOfBuffer.")
        }
    }
    func test_loadChildContent_Given_CorrectIterator_Expect_ChieldContent() {
        var iterator = initialSetup(with: [0x03, 0x61, 0x62, 0x63])
         
        do {
            let childContent = try sut.loadChildContent(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
            let resultedDataShouldBeLike = Data([0x61, 0x62, 0x63])
            XCTAssertEqual(childContent, resultedDataShouldBeLike)
        } catch {
            XCTFail("An error occurred: \(error)")
        }
    }
    func test_LoadChildContent_Given_EmptyInput() {
        var iterator = initialSetup(with: [])
         
        do {
            let contentData = try sut.loadChildContent(iterator: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form)
            XCTAssertTrue(contentData.isEmpty, "Empty input should result in empty content data.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    // MARK: decodeOID
    func test_decodeOID_Given_ValidOID_sha256_Expect_OID_sha256() {
        var contentData = Data([0x60, 0x86, 0x48, 0x1, 0x65, 0x3, 0x4, 0x2, 0x1])
        let decodedOID = sut.decodeOid(contentData: &contentData)
        XCTAssertEqual(decodedOID, OID.sha256.rawValue, "Valid OID should be correctly decoded.")
    }
    func test_decodeOID_Given_EmptyInput_Expect_Nill() {
        var contentData = Data([])
        let decodedOID = sut.decodeOid(contentData: &contentData)
        XCTAssertNil(decodedOID, "Empty input should result in nil.")
    }
    func test_DecodeOID_Given_ShortOIDInput_Expect_OID_organizationName() {
        var contentData = Data([0x55, 0x4, 0xa])
        let decodedOID = sut.decodeOid(contentData: &contentData)
        XCTAssertEqual(decodedOID, OID.organizationName.rawValue, "Short OID should be correctly decoded.")
    }
    // MARK: handleOthersClassTypeIdentifire
    func test_handleOthersClassTypeIdentifire_Given_CorrectLengthAndData() {
        var asn1obj = ASN1Object()
        var iterator = initialSetup(with: [0x03, 0x61, 0x62, 0x63])
        XCTAssertNoThrow(try sut.test_handleOthersClassTypeIdentifire(asn1obj: &asn1obj, atIteratio: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form))
        XCTAssertEqual(asn1obj.value as? String, "abc")
        XCTAssertEqual(asn1obj.rawValue, Data([0x61, 0x62, 0x63]))
    }
    func test_handleOthersClassTypeIdentifire_Given_LengthButInvalidData_Expect_Error_OutofBuffer() {
        var asn1obj = ASN1Object()
        var iterator = initialSetup(with: [0x03, 0x61, 0x62])
        XCTAssertThrowsError(try sut.test_handleOthersClassTypeIdentifire(asn1obj: &asn1obj, atIteratio: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form))
        XCTAssertNil(asn1obj.value)
        XCTAssertNil(asn1obj.rawValue)
    }
    func test_handleOthersClassTypeIdentifire_Given_OnlyLength() {
        var asn1obj = ASN1Object()
        var iterator = initialSetup(with: [0x03])
        XCTAssertThrowsError(try sut.test_handleOthersClassTypeIdentifire(asn1obj: &asn1obj, atIteratio: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form))
        XCTAssertNil(asn1obj.value)
        XCTAssertNil(asn1obj.rawValue)
    }
    func test_handleOthersClassTypeIdentifire_Given_Nothing() {
        var asn1obj = ASN1Object()
        var iterator = initialSetup(with: [])
        XCTAssertNoThrow(try sut.test_handleOthersClassTypeIdentifire(asn1obj: &asn1obj, atIteratio: &iterator, totalASN1ObjInUInt8Form: &totalASN1ObjInUInt8Form))
        XCTAssertNotNil(asn1obj.value)
        XCTAssertNotNil(asn1obj.rawValue)
    }
    // MARK: parse
    func test_parse_Given_String_Expect_String() {
        var iterator = initialSetup(with: [0x0C, 0x0D, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21])
        do {
            let asn1Array = try sut.parse(iterator: &iterator)
            XCTAssert(asn1Array.count == 1, "Should get only one object.")
            XCTAssertEqual(asn1Array.first?.rawValue, Data([0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x2C, 0x20, 0x57, 0x6F, 0x72, 0x6C, 0x64, 0x21]))
            XCTAssertEqual(asn1Array.first?.value as? String, "Hello, World!")
            XCTAssert(asn1Array.first?.childs == nil, "Should not get any child")
        } catch {
            XCTFail("should not through any error.")
        }
    }
    func test_parse_Given_OID__Expect_OID_sha256() {
        var iterator = initialSetup(with: [0x06, 0x09, 0x60, 0x86, 0x48, 0x1, 0x65, 0x3, 0x4, 0x2, 0x1])
        do {
            let asn1Array = try sut.parse(iterator: &iterator)
            XCTAssert(asn1Array.count == 1, "Should get only one object.")
            XCTAssertEqual(asn1Array.first?.rawValue, Data([0x60, 0x86, 0x48, 0x1, 0x65, 0x3, 0x4, 0x2, 0x1]))
            XCTAssertNotNil(asn1Array.first?.identifier, "Identifier should not be nill")
            XCTAssertEqual(asn1Array.first?.identifier?.tagNumber(), ASN1Identifier.TagNumber.objectIdentifier, "Expect an objectIdentifier tag type ASN1Identifier")
            XCTAssertEqual(asn1Array.first?.identifier?.typeClass(), ASN1Identifier.Class.universal, "Expect an universal class ASN1Identifier")
            XCTAssertEqual(asn1Array.first?.value as? String, OID.sha256.rawValue, "Expect OID_sha256")
            XCTAssert(asn1Array.first?.childs == nil, "Should not get any child")
            XCTAssertNil(asn1Array.first?.parent)
            XCTAssertEqual(asn1Array.first?.printAsn1(), "OBJECTIDENTIFIER: 2.16.840.1.101.3.4.2.1 (sha256)\n")
        } catch {
            XCTFail("should not through any error.")
        }
    }
    
    
    func test_random() {
        let stri = "30820122300d06092a864886f70d01010105000382010f003082010a0282010100be541df3ede409d2c431fa07609fe05d574ba2011d68bc7432c817270e92e7a894635db4081ae869e9db008f568558443b47482f625f2a7c5d3eaea2952ab156fe3e999864410bc70acc678bb7791f40b26d56e8fc59edc25ad1a1a384b773b26131688665872a433b0524dd542e26b03b9e334c065676c2d1691111f263a2559a46975572463f86f85154f7135193d2d0da8dbc4b620b25ea3eca9a9084751dc5374c9b604623a0ae5d7b08e9a27d97cdc6e9c51561a4d3af00d968fa88ddb8dc3b7330f4d8bf9b58724c02a0d004d328b899595a32b78a852c5f05c46ce1e6b17c8fde1244e6478eff5eb7ab93bf9640641e4965be0492699d5dac1e73e7ef0203010001"
        let decoder = ASN1Decoder()
        let obj = try? decoder.decode(data: stri.hexToData()!)
        print(obj?.first?.description)
    }
}

// MARK: Initial Setup
extension ASN1IDecoderTest {
    private func initialSetup(with asn1Object: [UInt8]) -> Data.Iterator {
        let lengthValueInDataFormat = Data(asn1Object)
        let iterator = lengthValueInDataFormat.makeIterator()
        return iterator
    }
}



extension String {
    func hexToData() -> Data? {
        var hex = self
        var data = Data()

        while !hex.isEmpty {
            let index = hex.index(hex.startIndex, offsetBy: 2)
            let hexByte = String(hex.prefix(upTo: index))
            hex = String(hex.suffix(from: index))

            if var byte = UInt8(hexByte, radix: 16) {
                data.append(&byte, count: 1)
            } else {
                // Invalid hex character
                return nil
            }
        }

        return data
    }
}

