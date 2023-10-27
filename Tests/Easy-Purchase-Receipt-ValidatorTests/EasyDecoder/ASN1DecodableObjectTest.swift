//
//  ASN1DecodableObjectTest.swift
//  
//
//  Created by BJIT on 27/10/23.
//

import XCTest
@testable import Easy_Purchase_Receipt_Validator

final class ASN1DecodableObjectTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    // MARK: - Sub-Object Access

    func test_subObjects_invalidIndex_returnsNil() {
        // Create an ASN1DecodableObject with two sub-objects.
        let object = ASN1DecodableObject()
        let subObject1 = ASN1DecodableObject()
        let subObject2 = ASN1DecodableObject()

        // Add the sub-objects to the parent object's subObjects.
        object.subObjects = [subObject1, subObject2]

        // Attempt to access a sub-object at an invalid index.
        XCTAssertNil(object.subObjects(2), "Sub-object at an invalid index should return nil.")
    }

    // MARK: - Subscript Access

    func test_subscript_invalidIndex_returnsNil() {
        // Create an ASN1DecodableObject with two sub-objects.
        let object = ASN1DecodableObject()
        let subObject1 = ASN1DecodableObject()
        let subObject2 = ASN1DecodableObject()

        // Add the sub-objects to the parent object's subObjects.
        object.subObjects = [subObject1, subObject2]

        // Attempt to access a sub-object using subscript at an invalid index.
        XCTAssertNil(object[2], "Sub-object at an invalid index (subscript) should return nil.")
    }

    // MARK: - Sub-Object Count

    func test_subCount_hasSubObjects_returnsCount() {
        // Create an ASN1DecodableObject with two sub-objects.
        let object = ASN1DecodableObject()
        let subObject1 = ASN1DecodableObject()
        let subObject2 = ASN1DecodableObject()

        // Add the sub-objects to the parent object's subObjects.
        object.subObjects = [subObject1, subObject2]

        // Check the count of sub-objects.
        XCTAssertEqual(object.subCount(), 2, "Sub-object count should match the number of sub-objects.")
    }

    func test_subCount_noSubObjects_returnsZero() {
        // Create an ASN1DecodableObject with no sub-objects.
        let object = ASN1DecodableObject()

        // Check the count of sub-objects.
        XCTAssertEqual(object.subCount(), 0, "Sub-object count should be zero when there are no sub-objects.")
    }

    // MARK: - Get Decodable Object by Type

    func test_getDecodableObjectByType_nonMatchingType_returnsNil() {
        // Create an ASN1DecodableObject with two sub-objects, each having different types.
        let object = ASN1DecodableObject()
        let subObject1 = ASN1DecodableObject()
        subObject1.asn1Tag = ASN1Tag(rawValue: 0x06) // Object Identifier tag
        let subObject2 = ASN1DecodableObject()
        subObject2.asn1Tag = ASN1Tag(rawValue: 0x02) // Integer tag

        // Add the sub-objects to the parent object's subObjects.
        object.subObjects = [subObject1, subObject2]

        // Attempt to retrieve a sub-object by type that doesn't match any sub-object's type.
        XCTAssertNil(object.getDecodableObject(by: ASN1ObjectType.rsaEncryption), "Should return nil when there is no matching type.")
    }

    // MARK: - Get Decodable Object by Tag

    func test_getDecodableObjectByTag_nonMatchingTag_returnsNil() {
        // Create an ASN1DecodableObject with two sub-objects, each having different tags.
        let object = ASN1DecodableObject()
        let subObject1 = ASN1DecodableObject()
        subObject1.asn1Tag = ASN1Tag(rawValue: 0x06) // Object Identifier tag
        let subObject2 = ASN1DecodableObject()
        subObject2.asn1Tag = ASN1Tag(rawValue: 0x02) // Integer tag

        // Add the sub-objects to the parent object's subObjects.
        object.subObjects = [subObject1, subObject2]

        // Attempt to retrieve a sub-object by tag that doesn't match any sub-object's tag.
        XCTAssertNil(object.getDecodableObject(by: "1.2.840.113549.1.1.1"), "Should return nil when there is no matching tag.")
    }

    // MARK: - AsString

    func test_asString_withStringSubObject_returnsString() {
        // Create an ASN1DecodableObject with a sub-object containing a string value.
        let object = ASN1DecodableObject()
        let subObject1 = ASN1DecodableObject()
        subObject1.value = "Hello, World!"

        // Add the sub-object to the parent object's subObjects.
        object.subObjects = [subObject1]

        // Retrieve the value as a string.
        XCTAssertEqual(object.asString, "Hello, World!", "Should return the string value.")
    }

    func test_asString_noStringSubObject_returnsNil() {
        // Create an ASN1DecodableObject with a sub-object containing a non-string value (e.g., an integer).
        let object = ASN1DecodableObject()
        let subObject1 = ASN1DecodableObject()
        subObject1.value = 123

        // Add the sub-object to the parent object's subObjects.
        object.subObjects = [subObject1]

        // Attempt to retrieve the value as a string.
        XCTAssertNil(object.asString, "Should return nil when there is no string value.")
    }

    // MARK: - Description

    func test_description_withTagAndValue_returnsWrongFormattedDescription() {
        // Create an ASN1DecodableObject with a specific tag and value.
        let object = ASN1DecodableObject()
        object.asn1Tag = ASN1Tag(rawValue: 0x06) // Object Identifier tag
        object.value = "1.2.840.10040.4.1"

        // Check the description.
        let expectedDescription = "OBJECTIDENTIFIER: 1.2.840.10040.4.1 (etsiQcsCompliance)"
        XCTAssertNotEqual(object.description, expectedDescription, "Description should be formatted incorrectly.")
    }
    
    func test_description_withTagAndValue_returnsFormattedDescription() {
        // Create an ASN1DecodableObject with a specific tag and value.
        let object = ASN1DecodableObject()
        object.asn1Tag = ASN1Tag(rawValue: 0x06) // Object Identifier tag
        object.value = "0.4.0.1862.1.1"

        // Check the description.
        let expectedDescription = "OBJECTIDENTIFIER: 0.4.0.1862.1.1 (etsiQcsCompliance)"
        XCTAssertEqual(object.description, expectedDescription, "Description should be formatted correctly.")
    }

    func test_description_withoutValue_returnsTagDescription() {
        // Create an ASN1DecodableObject with a specific tag but no value.
        let object = ASN1DecodableObject()
        object.asn1Tag = ASN1Tag(rawValue: 0x06) // Object Identifier tag

        // Check the description.
        let expectedDescription = "OBJECTIDENTIFIER"
        XCTAssertEqual(object.description, expectedDescription, "Description should be the tag description.")
    }

    // MARK: - Parent Reference

    func test_parentReference_noParentObject_returnsNil() {
        // Create an ASN1DecodableObject with no parent object.
        let childObject = ASN1DecodableObject()

        // Check the parent reference.
        XCTAssertNil(childObject.parent, "Parent reference should be nil when there is no parent object.")
    }
}
