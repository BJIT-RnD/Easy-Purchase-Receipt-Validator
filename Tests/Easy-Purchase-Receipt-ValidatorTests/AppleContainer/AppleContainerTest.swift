//
//  AppleContainerTest.swift
//  
//
//  Created by BJIT on 13/11/23.
//

import XCTest
@testable import Easy_Purchase_Receipt_Validator
final class AppleContainerTest: XCTestCase {
    var appleContainer: AppleContainer!
    override func tearDown() {
        super.tearDown()
        self.appleContainer = nil
    }
    func test_ReceiptParsing_whenValidDataGiven_shouldNotGetNil() {
        // Test receipt parsing with valid data
        guard let validReceiptData = Data(base64Encoded: easyPurchaseSandboxReceipt) else {
            XCTFail("Invalid Base64 format")
            return
        }
        appleContainer = try? AppleContainer(data: validReceiptData)
        XCTAssertNotNil(appleContainer)
        
        let payloadData = appleContainer.AppleReceipt()
        XCTAssertNotNil(payloadData)
    }
    
    func test_ReceiptParsing_whenInvalidDataGiven_shouldReturnNil() {
        // Test receipt parsing with empty data
        let emptyReceiptData = Data()
        appleContainer = try? AppleContainer(data: emptyReceiptData)
        XCTAssertNil(appleContainer)
    }
    
    func test_receiptData_whenValidReceiptGiven_shouldReturnValidData() {
        guard let data = Data(base64Encoded: easyPurchaseSandboxReceipt) else {
            XCTFail("Invalid Base64 format")
            return
        }
        // Act
        let appleContainer = try? AppleContainer(data: data)
        guard let receipt = appleContainer?.AppleReceipt() else {
            XCTFail("Invalid Receipt format")
            return
        }
        // Assert
        XCTAssertEqual(receipt.bundleIdentifier, "com.bjitgroup.easypurchase", "Incorrect bundle identifier")
        XCTAssertEqual(receipt.bundleVersion, "1", "Incorrect bundle version")
        XCTAssertEqual(receipt.originalApplicationVersion, "1.0", "Incorrect original application version")
        XCTAssertEqual(receipt.receiptCreationDateString, "2023-11-13T07:07:43Z", "Incorrect creation date")
        XCTAssertEqual(receipt.sha1Hash?.hexEncodedString(), "987868CF3C0882E331BC1BB699A04D5E983B8805", "Incorrect SHA1 hash")
        XCTAssertEqual(receipt.opaqueValue?.hexEncodedString(), "F32757D0012E48CE7E2DDE97E8F27FBD", "Incorrect opaque value")
    }
    
    func test_productCount_whenTwoPurchasedProduct_shouldReturnTwo() {
        guard let data = Data(base64Encoded: easyPurchaseSandboxReceipt) else {
            XCTFail("Invalid Base64 format")
            return
        }
        // Act
        let appleContainer = try? AppleContainer(data: data)
        guard let receipt = appleContainer?.AppleReceipt() else {
            XCTFail("Invalid Receipt format")
            return
        }
        // Assert
        XCTAssertEqual(receipt.inAppPurchasesReceipt?.count, 2, "Incorrect number of purchased products")
    }
    
    func test_firstProductInfo_whenValidReceiptGiven_shouldReturnValidInfo() {
        guard let data = Data(base64Encoded: easyPurchaseSandboxReceipt) else {
            XCTFail("Invalid Base64 format")
            return
        }
        // Act
        let appleContainer = try? AppleContainer(data: data)
        guard let receipt = appleContainer?.AppleReceipt() else {
            XCTFail("Invalid Receipt format")
            return
        }
        // Assert
        XCTAssertEqual(receipt.inAppPurchasesReceipt?.first?.productIdentifier, "com.bjitgroup.easypurchase.consumable.tencoin", "Incorrect product identifier")
        XCTAssertEqual(receipt.inAppPurchasesReceipt?.first?.quantities, 1, "Incorrect quantity")
        XCTAssertEqual(receipt.inAppPurchasesReceipt?.first?.transactionId, "2000000456998762", "Incorrect transaction ID")
    }



/* This sample receipt is taken from Demo App in Sandbox environment. This is real receipt received by apple. It contains two purchased product invoice.
 - Consumable 10 coins purchased at 13Nov 2023
 - Non-Consumable Level 1 purchased at 30Oct 2023
 */
let easyPurchaseSandboxReceipt = "MIIV8AYJKoZIhvcNAQcCoIIV4TCCFd0CAQExCzAJBgUrDgMCGgUAMIIFLgYJKoZIhvcNAQcBoIIFHwSCBRsxggUXMAoCAQgCAQEEAhYAMAoCARQCAQEEAgwAMAsCAQECAQEEAwIBADALAgEDAgEBBAMMATEwCwIBCwIBAQQDAgEAMAsCAQ8CAQEEAwIBADALAgEQAgEBBAMCAQAwCwIBGQIBAQQDAgEDMAwCAQoCAQEEBBYCNCswDAIBDgIBAQQEAgIA4TANAgENAgEBBAUCAwJyLTANAgETAgEBBAUMAzEuMDAOAgEJAgEBBAYCBFAzMDIwGAIBBAIBAgQQ8ydX0AEuSM5+Ld6X6PJ/vTAbAgEAAgEBBBMMEVByb2R1Y3Rpb25TYW5kYm94MBwCAQUCAQEEFJh4aM88CILjMbwbtpmgTV6YO4gFMB4CAQwCAQEEFhYUMjAyMy0xMS0xM1QwNzowNzo0M1owHgIBEgIBAQQWFhQyMDEzLTA4LTAxVDA3OjAwOjAwWjAkAgECAgEBBBwMGmNvbS5iaml0Z3JvdXAuZWFzeXB1cmNoYXNlMEkCAQcCAQEEQeGL8ybsU83T4kYFbvPMFEmCQ2+d2socbV1eMouD5M0131gWmALmocbAB7OUUqsCzyE9+Smg1rFCTTEnPc98Fi5ZMFMCAQYCAQEESzcNaT6dHzFOqEcBZNaA4uLi/xXuS8c9GLkHPAjb4GccrWV6AJiEl2i0ciMISovHwCjM05taGzu5YL+dqMJoBK8dO9fgmwA4TNTk2DCCAYACARECAQEEggF2MYIBcjALAgIGrAIBAQQCFgAwCwICBq0CAQEEAgwAMAsCAgawAgEBBAIWADALAgIGsgIBAQQCDAAwCwICBrMCAQEEAgwAMAsCAga0AgEBBAIMADALAgIGtQIBAQQCDAAwCwICBrYCAQEEAgwAMAwCAgalAgEBBAMCAQEwDAICBqsCAQEEAwIBATAMAgIGrgIBAQQDAgEAMAwCAgavAgEBBAMCAQAwDAICBrECAQEEAwIBADAMAgIGugIBAQQDAgEAMBsCAganAgEBBBIMEDIwMDAwMDA0NTY5OTg3NjIwGwICBqkCAQEEEgwQMjAwMDAwMDQ1Njk5ODc2MjAfAgIGqAIBAQQWFhQyMDIzLTExLTEzVDA3OjA3OjQwWjAfAgIGqgIBAQQWFhQyMDIzLTExLTEzVDA3OjA3OjQwWjA4AgIGpgIBAQQvDC1jb20uYmppdGdyb3VwLmVhc3lwdXJjaGFzZS5jb25zdW1hYmxlLnRlbmNvaW4wggGEAgERAgEBBIIBejGCAXYwCwICBqwCAQEEAhYAMAsCAgatAgEBBAIMADALAgIGsAIBAQQCFgAwCwICBrICAQEEAgwAMAsCAgazAgEBBAIMADALAgIGtAIBAQQCDAAwCwICBrUCAQEEAgwAMAsCAga2AgEBBAIMADAMAgIGpQIBAQQDAgEBMAwCAgarAgEBBAMCAQAwDAICBq4CAQEEAwIBADAMAgIGrwIBAQQDAgEAMAwCAgaxAgEBBAMCAQAwDAICBroCAQEEAwIBADAbAgIGpwIBAQQSDBAyMDAwMDAwNDQ2NDU3OTg5MBsCAgapAgEBBBIMEDIwMDAwMDA0NDY0NTc5ODkwHwICBqgCAQEEFhYUMjAyMy0xMC0zMFQwMzo0NDozOFowHwICBqoCAQEEFhYUMjAyMy0xMC0zMFQwMzo0NDozOFowPAICBqYCAQEEMwwxY29tLmJqaXRncm91cC5lYXN5cHVyY2hhc2Uubm9uY29uc3VtYWJsZS5sZXZlbG9uZaCCDuIwggXGMIIErqADAgECAhAtqwMbvdZlc9IHKXk8RJfEMA0GCSqGSIb3DQEBBQUAMHUxCzAJBgNVBAYTAlVTMRMwEQYDVQQKDApBcHBsZSBJbmMuMQswCQYDVQQLDAJHNzFEMEIGA1UEAww7QXBwbGUgV29ybGR3aWRlIERldmVsb3BlciBSZWxhdGlvbnMgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMjIxMjAyMjE0NjA0WhcNMjMxMTE3MjA0MDUyWjCBiTE3MDUGA1UEAwwuTWFjIEFwcCBTdG9yZSBhbmQgaVR1bmVzIFN0b3JlIFJlY2VpcHQgU2lnbmluZzEsMCoGA1UECwwjQXBwbGUgV29ybGR3aWRlIERldmVsb3BlciBSZWxhdGlvbnMxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwN3GrrTovG3rwX21zphZ9lBYtkLcleMaxfXPZKp/0sxhTNYU43eBxFkxtxnHTUurnSemHD5UclAiHj0wHUoORuXYJikVS+MgnK7V8yVj0JjUcfhulvOOoArFBDXpOPer+DuU2gflWzmF/515QPQaCq6VWZjTHFyKbAV9mh80RcEEzdXJkqVGFwaspIXzd1wfhfejQebbExBvbfAh6qwmpmY9XoIVx1ybKZZNfopOjni7V8k1lHu2AM4YCot1lZvpwxQ+wRA0BG23PDcz380UPmIMwN8vcrvtSr/jyGkNfpZtHU8QN27T/D0aBn1sARTIxF8xalLxMwXIYOPGA80mgQIDAQABo4ICOzCCAjcwDAYDVR0TAQH/BAIwADAfBgNVHSMEGDAWgBRdQhBsG7vHUpdORL0TJ7k6EneDKzBwBggrBgEFBQcBAQRkMGIwLQYIKwYBBQUHMAKGIWh0dHA6Ly9jZXJ0cy5hcHBsZS5jb20vd3dkcmc3LmRlcjAxBggrBgEFBQcwAYYlaHR0cDovL29jc3AuYXBwbGUuY29tL29jc3AwMy13d2RyZzcwMTCCAR8GA1UdIASCARYwggESMIIBDgYKKoZIhvdjZAUGATCB/zA3BggrBgEFBQcCARYraHR0cHM6Ly93d3cuYXBwbGUuY29tL2NlcnRpZmljYXRlYXV0aG9yaXR5LzCBwwYIKwYBBQUHAgIwgbYMgbNSZWxpYW5jZSBvbiB0aGlzIGNlcnRpZmljYXRlIGJ5IGFueSBwYXJ0eSBhc3N1bWVzIGFjY2VwdGFuY2Ugb2YgdGhlIHRoZW4gYXBwbGljYWJsZSBzdGFuZGFyZCB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB1c2UsIGNlcnRpZmljYXRlIHBvbGljeSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0ZW1lbnRzLjAwBgNVHR8EKTAnMCWgI6Ahhh9odHRwOi8vY3JsLmFwcGxlLmNvbS93d2RyZzcuY3JsMB0GA1UdDgQWBBSyRX3DRIprTEmvblHeF8lRRu/7NDAOBgNVHQ8BAf8EBAMCB4AwEAYKKoZIhvdjZAYLAQQCBQAwDQYJKoZIhvcNAQEFBQADggEBAHeKAt2kspClrJ+HnX5dt7xpBKMa/2Rx09HKJqGLePMVKT5wzOtVcCSbUyIJuKsxLJZ4+IrOFovPKD4SteF6dL9BTFkNb4BWKUaBj+wVlA9Q95m3ln+Fc6eZ7D4mpFTsx77/fiR/xsTmUBXxWRvk94QHKxWUs5bp2J6FXUR0rkXRqO/5pe4dVhlabeorG6IRNA03QBTg6/Gjx3aVZgzbzV8bYn/lKmD2OV2OLS6hxQG5R13RylulVel+o3sQ8wOkgr/JtFWhiFgiBfr9eWthaBD/uNHuXuSszHKEbLMCFSuqOa+wBeZXWw+kKKYppEuHd52jEN9i2HloYOf6TsrIZMswggRVMIIDPaADAgECAhQ0GFj/Af4GP47xnx/pPAG0wUb/yTANBgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzETMBEGA1UEChMKQXBwbGUgSW5jLjEmMCQGA1UECxMdQXBwbGUgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkxFjAUBgNVBAMTDUFwcGxlIFJvb3QgQ0EwHhcNMjIxMTE3MjA0MDUzWhcNMjMxMTE3MjA0MDUyWjB1MQswCQYDVQQGEwJVUzETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UECwwCRzcxRDBCBgNVBAMMO0FwcGxlIFdvcmxkd2lkZSBEZXZlbG9wZXIgUmVsYXRpb25zIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArK7R07aKsRsola3eUVFMPzPhTlyvs/wC0mVPKtR0aIx1F2XPKORICZhxUjIsFk54jpJWZKndi83i1Mc7ohJFNwIZYmQvf2HG01kiv6v5FKPttp6Zui/xsdwwQk+2trLGdKpiVrvtRDYP0eUgdJNXOl2e3AH8eG9pFjXDbgHCnnLUcTaxdgl6vg0ql/GwXgsbEq0rqwffYy31iOkyEqJVWEN2PD0XgB8p27Gpn6uWBZ0V3N3bTg/nE3xaKy4CQfbuemq2c2D3lxkUi5UzOJPaACU2rlVafJ/59GIEB3TpHaeVVyOsKyTaZE8ocumWsAg8iBsUY0PXia6YwfItjuNRJQIDAQABo4HvMIHsMBIGA1UdEwEB/wQIMAYBAf8CAQAwHwYDVR0jBBgwFoAUK9BpR5R2Cf70a40uQKb3R01/CF4wRAYIKwYBBQUHAQEEODA2MDQGCCsGAQUFBzABhihodHRwOi8vb2NzcC5hcHBsZS5jb20vb2NzcDAzLWFwcGxlcm9vdGNhMC4GA1UdHwQnMCUwI6AhoB+GHWh0dHA6Ly9jcmwuYXBwbGUuY29tL3Jvb3QuY3JsMB0GA1UdDgQWBBRdQhBsG7vHUpdORL0TJ7k6EneDKzAOBgNVHQ8BAf8EBAMCAQYwEAYKKoZIhvdjZAYCAQQCBQAwDQYJKoZIhvcNAQEFBQADggEBAFKjCCkTZbe1H+Y0A+32GHe8PcontXDs7GwzS/aZJZQHniEzA2r1fQouK98IqYLeSn/h5wtLBbgnmEndwQyG14FkroKcxEXx6o8cIjDjoiVhRIn+hXpW8HKSfAxEVCS3taSfJvAy+VedanlsQO0PNAYGQv/YDjFlbeYuAdkGv8XKDa5H1AUXiDzpnOQZZG2KlK0R3AH25Xivrehw1w1dgT5GKiyuJKHH0uB9vx31NmvF3qkKmoCxEV6yZH6zwVfMwmxZmbf0sN0x2kjWaoHusotQNRbm51xxYm6w8lHiqG34Kstoc8amxBpDSQE+qakAioZsg4jSXHBXetr4dswZ1bAwggS7MIIDo6ADAgECAgECMA0GCSqGSIb3DQEBBQUAMGIxCzAJBgNVBAYTAlVTMRMwEQYDVQQKEwpBcHBsZSBJbmMuMSYwJAYDVQQLEx1BcHBsZSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEWMBQGA1UEAxMNQXBwbGUgUm9vdCBDQTAeFw0wNjA0MjUyMTQwMzZaFw0zNTAyMDkyMTQwMzZaMGIxCzAJBgNVBAYTAlVTMRMwEQYDVQQKEwpBcHBsZSBJbmMuMSYwJAYDVQQLEx1BcHBsZSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEWMBQGA1UEAxMNQXBwbGUgUm9vdCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOSRqQkfkdseR1DrBe1eeYQt6zaiV0xV7IsZid75S2z1B6siMALoGD74UAnTf0GomPnRymacJGsR0KO75Bsqwx+VnnoMpEeLW9QWNzPLxA9NzhRp0ckZcvVdDtV/X5vyJQO6VY9NXQ3xZDUjFUsVWR2zlPf2nJ7PULrBWFBnjwi0IPfLrCwgb3C2PwEwjLdDzw+dPfMrSSgayP7OtbkO2V4c1ss9tTqt9A8OAJILsSEWLnTVPA3bYharo3GSR1NVwa8vQbP4++NwzeajTEV+H0xrUJZBicR0YgsQg0GHM4qBsTBY7FoEMoxos48d3mVz/2deZbxJ2HafMxRloXeUyS0CAwEAAaOCAXowggF2MA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQr0GlHlHYJ/vRrjS5ApvdHTX8IXjAfBgNVHSMEGDAWgBQr0GlHlHYJ/vRrjS5ApvdHTX8IXjCCAREGA1UdIASCAQgwggEEMIIBAAYJKoZIhvdjZAUBMIHyMCoGCCsGAQUFBwIBFh5odHRwczovL3d3dy5hcHBsZS5jb20vYXBwbGVjYS8wgcMGCCsGAQUFBwICMIG2GoGzUmVsaWFuY2Ugb24gdGhpcyBjZXJ0aWZpY2F0ZSBieSBhbnkgcGFydHkgYXNzdW1lcyBhY2NlcHRhbmNlIG9mIHRoZSB0aGVuIGFwcGxpY2FibGUgc3RhbmRhcmQgdGVybXMgYW5kIGNvbmRpdGlvbnMgb2YgdXNlLCBjZXJ0aWZpY2F0ZSBwb2xpY3kgYW5kIGNlcnRpZmljYXRpb24gcHJhY3RpY2Ugc3RhdGVtZW50cy4wDQYJKoZIhvcNAQEFBQADggEBAFw2mUwteLftjJvc83eb8nbSdzBPwR+Fg4UbmT1HN/Kpm0COLNSxkBLYvvRzm+7SZA/LeU802KI++Xj/a8gH7H05g4tTINM4xLG/mk8Ka/8r/FmnBQl8F0BWER5007eLIztHo9VvJOLr0bdw3w9F4SfK8W147ee1Fxeo3H4iNcol1dkP1mvUoiQjEfehrI9zgWDGG1sJL5Ky+ERI8GA4nhX1PSZnIIozavcNgs/e66Mv+VNqW2TAYzN39zoHLFbr2g8hDtq6cxlPtdk2f8GHVdmnmbkyQvvY1XGefqFStxu9k0IkEirHDx22TZxeY8hLgBdQqorV2uT80AkHN7B1dSExggGxMIIBrQIBATCBiTB1MQswCQYDVQQGEwJVUzETMBEGA1UECgwKQXBwbGUgSW5jLjELMAkGA1UECwwCRzcxRDBCBgNVBAMMO0FwcGxlIFdvcmxkd2lkZSBEZXZlbG9wZXIgUmVsYXRpb25zIENlcnRpZmljYXRpb24gQXV0aG9yaXR5AhAtqwMbvdZlc9IHKXk8RJfEMAkGBSsOAwIaBQAwDQYJKoZIhvcNAQEBBQAEggEAPDhBbg0/UYV2MmpKW0sIt7X081zZvUAQHaT0HZmraheK3Pvetcx9nwhFJyVXsq2HBx/5aZ1dW1P98DkO0m1PNTcR9+Xm5efeYXe3hThXgLDRjP90Rm6VH22APngIiVxQa6+KibIlkLNUrSz3C/hBcAmQtzmrUg6Se8XFAj0C6phHaMY7aLrE9oEVxfxVV1FGEL+qzcpYczNFHFy8gzSI2AUNKuIBjkGfcPeXnLgA4jwsHfcyfFDgsCbiSDlHeDc9FDurXd9s6fu/j+3beOu8snIyHY761fl5QyDHqUlucJOnC5g/PLyA8pm8/Oka1zeM0qx0LIOqNMBuzJ4f4njQyQ=="
}
