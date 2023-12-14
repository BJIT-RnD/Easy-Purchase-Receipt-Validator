//
//  InterfaceFunctionalityVC.swift
//  Demo
//
//  Created by BJIT on 11/12/23.
//

import UIKit
import Easy_Purchase_Receipt_Validator

class InterfaceFunctionalityVC: UIViewController {
    @IBOutlet weak var checkValidationStatus: UILabel!
    @IBOutlet weak var ifContainStatus: UILabel!
    @IBOutlet weak var allPurchaseStatus: UILabel!
    @IBOutlet weak var activeAutoRenewStatus: UILabel!
    @IBOutlet weak var nonRenewValidationStatus: UILabel!
    
    @IBOutlet weak var ifContainTB: UITextField!
    
    @IBOutlet weak var nonRenewDateTB: UITextField!
    @IBOutlet weak var nonRenewTB: UITextField!
    @IBOutlet weak var allPurchaseTB: UITextField!
    
    var receipt: InAppReceiptValidatorProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let receiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: receiptURL.path) {
            let receiptData = try? Data(contentsOf: receiptURL, options: .alwaysMapped)
            do {
                let appleContainer = try AppleContainer(data: receiptData!)
                receipt = try appleContainer.AppleReceipt()
            } catch {
                print("Error Occured during parsing receipt data")
            }
        }
    }
    
    @IBAction func checkValidation(_ sender: Any) {
        let isValid = try? receipt?.isValidReceipt()
        checkValidationStatus.text = "\(isValid)"
    }
    
    @IBAction func checkIfContain(_ sender: Any) {
        let id = ifContainTB.text
        let isContainPurchase = try? receipt?.containsPurchase(ofProductIdentifier: id ?? "xyz")
        ifContainStatus.text = "\(isContainPurchase)"
    }
    @IBAction func checkAllPurchase(_ sender: Any) {
        let id = allPurchaseTB.text
        let allPurchaseCount = try? receipt?.allPurchasesByProductId(ofProductIdentifier: id ?? "abc", sortedBy: nil).count
        allPurchaseStatus.text = "\(allPurchaseCount)"
    }
    @IBAction func activeAutoRenews(_ sender: Any) {
        let allActivePurchaseCount = try? receipt?.activeAutoRenewables().count
        activeAutoRenewStatus.text = "\(allActivePurchaseCount)"
    }
    @IBAction func nonRenewValidationCheck(_ sender: Any) {
        let id = nonRenewTB.text
        let date = Int(nonRenewDateTB.text ?? "1")
        let nonRenewValid = try? receipt?.isNonRenewableActive(productIdentifier: id ?? "abc", validForDay: date ?? 1, currentDate: Date())
        nonRenewValidationStatus.text = "\(nonRenewValid)"
    }
}
