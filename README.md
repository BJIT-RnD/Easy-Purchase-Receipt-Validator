# Easy Purchase Reciept Validator
![Receipt Validator](IAP_Validation_Banner.png)

**Easy Purchase Reciept Validator** is a minimalistic, entirely Swift-based library designed for locally interpreting and authenticating Apple In-App Purchase Receipts.

## Features
- Access details from every In-App Receipt attribute
- Verify the In-App Purchase Receipt (including Signature, Bundle Version, and Identifier, Hash)
- **iOS 11+ Ready**: Offers support for in-app purchases initiated from the App Store (compatible with iOS 11 onwards).
- **User-Friendly API**: Enjoy an easily comprehensible block-based API.

## Requirements

All the features should be available if you are maintaining or developing app with lowest iOS version set as 11.0. So, only requirements for iOS devices:

- **iOS:** 11.0
# Installation

You have multiple options for installing Easy Purchase Receipt Validator in your project, with the preferred and recommended approaches being Swift Package Manager, CocoaPods, and Carthage integrations.

Regardless of the method you choose, make sure to import the project wherever you intend to use it:

```swift
import Easy_Purchase_Receipt_Validator
```


## Swift Package Manager

The Swift Package Manager (SPM) is a tool for automating the distribution of Swift code and is seamlessly integrated into Xcode and the Swift compiler. It is the recommended installation method for Easy Purchase Reciept Validator. With SPM, updates to Easy Purchase Reciept Validator are immediately available to your projects. SPM is also directly integrated with Xcode.

If you are using Xcode 11 or later, follow these steps to add Easy_Purchase_Receipt_Validator as a dependency:

1. Click on **File**.
2. Select **Swift Packages**.
3. Choose **Add Package Dependency...**.
4. Specify the git URL for Easy_Purchase_Receipt_Validator :

```swift 
https://github.com/BJIT-RnD/Easy-Purchase-Receipt-Validator.git
```

## CocoaPods

Easy Purchase Reciept Validator can be installed as a CocoaPod and builds as a Swift framework. 

To install, include this in your Podfile.
```swift
use_frameworks!

pod ‘Easy_Purchase_Receipt_Validator'
```

## Usage Guidelines

### Intializing with receipt
> 
Our library will ensure that your receipt will be decoded following the rules and will return the decoded data to the developer who will be using our library.

To initiate the validation process, follow these steps:

1. Load the receipt from your bundle's appStoreReceiptURL.

```swift
if let receiptURL = Bundle.main.appStoreReceiptURL,
   FileManager.default.fileExists(atPath: receiptURL.path) {
    let receiptData = try? Data(contentsOf: receiptURL, options: .alwaysMapped)
    do {
        // Continue with the validation process
    } catch {
        // Handle errors during the loading of receipt data
    }
}
```
2. To continue validation process and catch error

```swift
do {
    let appleContainer = try AppleContainer(data: receiptData!)
    let receiptData = try appleContainer.AppleReceipt()
} catch {
    // Handle errors during the parsing of receipt data
    // e.g., print("Error occurred during parsing receipt data")
}
```
Ensure to incorporate these code snippets into your application to effectively load and validate the In-App Purchase Receipt. Adjust error-handling mechanisms based on your application's requirements.

## Receipt Validation 

After getting receiptData successfully from above block, you can check the validty of the data:


```swift
do {
    let receiptValidityCheck = try receiptData.isValidReceipt()
} catch ReceiptError.verificationFailed {
    // Do something if verification is failed
}
```

NOTE: Apple strongly advises conducting receipt validation promptly upon your app's launch. For enhanced security measures, consider periodically rechecking the validation while your application is active. Additionally, in the event of a validation failure on iOS, it is recommended to attempt a receipt refresh initially.

### Accessing Various Information Regarding Validated Receipt

After making sure that you have the validated receipt, you can access various information from the receipt as per your need.

1. Accessing Bundle Identifier
```swift
let bundleIdentifier = receiptData.bundleIdentifier
```
2. Accessing Original AppVersion
```swift
let originalAppVersion = receiptData.originalAppVersion
```
3. Accessing BundleVersion
```swift
let bundleVersion = receiptData.bundleVersion
```
4. Accessing List of Purchases
```swift
guard let purchase = receiptData.purchases else { return }
```
5. Accessing Opaque Value
```swift
let opaqueValue = receiptData.opaqueValue
```
6. Accessing Bundle Identifier Data
```swift
let bundleIdentifierData = receiptData.bundleIdentifierData
```
7. Accessing receiptHash
```swift
let receiptHash = receiptData.receiptHash
```
8. Accessing Receipt Creation Date
```swift
let receiptCreationDate = receiptData.creationDate
```
9. Accessing Receipt Expiration Date
```swift
let receiptExpirationDate = receiptData.expirationDate
```
10. Accessing Receipt Creation Date as String
```swift
let creationDateString = receiptData.creationDateString
```
11. Accessing Receipt Expiration Date as String
```swift
let expirationDateString = receiptData.expirationDateString
```
### Few Useful Methods

This part explains how to call different methods of our library which will do specific tasks according to your neccessary.

Atomic: Appropriate when the content is instantly delivered.
```swift
    /// Returns the original transaction identifier for the first purchase of a specific product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier.
    /// - Returns: The original transaction identifier, or `nil` if no purchases exist.
    public func originalTransactionIdentifier(ofProductIdentifier productIdentifier: String) -> String? 

    // MARK: Contains Purchase

    /// Checks if there is a purchase for a specific product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier.
    /// - Returns: `true` if the product has been purchased, `false` otherwise.
    public func containsPurchase(ofProductIdentifier productIdentifier: String) -> Bool

    // MARK: Purchase Expired Date

    /// Returns the expiration date of the first purchase for a specific product identifier.
    ///
    /// - Parameter productIdentifier: The product identifier.
    /// - Returns: The expiration date, or `nil` if no purchases exist or the expiration date is `nil`.
    public func getPurchaseExpiredDatebyProductId(ofProductIdentifier productIdentifier: String) throws -> Date?

    // MARK: Purchases

    /// Returns an array of purchases for a specific product identifier.
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier.
    ///   - sort: An optional sorting block for the purchases.
    /// - Returns: An array of purchases, sorted if a sorting block is provided.
    public func allPurchasesByProductId(ofProductIdentifier productIdentifier: String,
                   sortedBy sort: ((PurchaseData, PurchaseData) -> Bool)? = nil) -> [PurchaseData]

    // MARK: Currently Active Auto-Renewable Subscription Purchases Within a Specific Date

    /// Returns the currently active auto-renewable subscription purchase for a specific product identifier and date.
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier.
    ///   - date: The date for which the subscription's status is checked.
    /// - Returns: The active auto-renewable subscription purchase, or `nil` if none is found.
    ///
    public func isActiveAutoRenewableByDate(ofProductIdentifier productIdentifier: String, forDate date: Date) throws -> PurchaseData?

    // MARK: Currently Active Auto-Renewable Subscription Purchases

    /// Returns the currently active auto-renewable subscription purchase for a specific product identifier.
    ///
    /// - Parameters:
    ///   - productIdentifier: The product identifier.
    /// - Returns: The active auto-renewable subscription purchase by checking current date using Date(), or `nil` if none is found.
    ///
    public func isCurrentlyActiveAutoRenewable(ofProductIdentifier productIdentifier: String) throws -> PurchaseData?
    
    // MARK: All Auto-renewable products receipt containing

    /// Returns all the auto-renewable subscription purchase ever done by the user.
    ///
    /// - Returns: The list of all the auto-renewable subscription purchase ever done by the user.
    ///
    public var allAutoRenewables: [PurchaseData] 
    
    // MARK: All Active Auto-renewable products receipt containing

    /// Returns all the active auto-renewable subscription purchases.
    ///
    /// - Returns: The list of all the active auto-renewable subscription purchase ever done by the user.
    ///

    // MARK: - Non-Renewable Product Validation

    /// Determines the validity of a non-renewable product based on a specified number of days.
    ///
    /// - Parameters:
    ///   - productIdentifier: The identifier of the non-renewable product.
    ///   - day: The number of days the product is considered valid.
    ///   - currentDate: The current date for comparison.
    /// - Returns: `true` if the product is valid, `false` otherwise.
    /// - Throws: An error if there are issues with product purchase or date calculations.
    public func isNonRenewableActive(productIdentifier: String, validForDay day: Int, currentDate: Date) throws -> Bool 

    /// Determines the validity of a non-renewable product based on a specified number of months.
    ///
    /// - Parameters:
    ///   - productIdentifier: The identifier of the non-renewable product.
    ///   - month: The number of months the product is considered valid.
    ///   - currentDate: The current date for comparison.
    /// - Returns: `true` if the product is valid, `false` otherwise.
    /// - Throws: An error if there are issues with product purchase or date calculations.
    public func isNonRenewableActive(productIdentifier: String, validForMonth month: Int, currentDate: Date) throws -> Bool

    /// Determines the validity of a non-renewable product based on a specified number of years.
    ///
    /// - Parameters:
    ///   - productIdentifier: The identifier of the non-renewable product.
    ///   - year: The number of years the product is considered valid.
    ///   - currentDate: The current date for comparison.
    /// - Returns: `true` if the product is valid, `false` otherwise.
    /// - Throws: An error if there are issues with product purchase or date calculations.
    public func isNonRenewableActive(productIdentifier: String, validForYear year: Int, currentDate: Date) throws -> Bool

    /// Private method for checking the validity of a non-renewable product.
    ///
    /// - Parameters:
    ///   - productIdentifier: The identifier of the non-renewable product.
    ///   - activeDays: The total number of days the product is considered valid.
    ///   - currentDate: The current date for comparison.
    /// - Returns: `true` if the product is valid, `false` otherwise.
    /// - Throws: An error if there are issues with product purchase or date calculations.
    private func checkNonRenewableValidity(productIdentifier: String, activeDays: Int, currentDate: Date) throws -> Bool  
```
## N.B.

Easy Purchase Receipt Validator does not retain in-app purchase data on a local level. The responsibility for managing and storing this data falls upon the clients or developers who use this library. They have the flexibility to choose their preferred storage solution, which could include options such as NSUserDefaults, CoreData, or the Keychain. In other words, This library doesn't handle the local storage of in-app purchase information; that task is left to the discretion of the clients, allowing them to select the most suitable method for their specific needs.
