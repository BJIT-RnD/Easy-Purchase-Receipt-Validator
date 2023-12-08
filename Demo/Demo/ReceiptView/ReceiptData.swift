//
//  ReceiptData.swift
//  Demo
//
//  Created by BJIT on 8/12/23.
//

import UIKit
import Easy_Purchase_Receipt_Validator

class ReceiptData: UIViewController {

    @IBOutlet weak var tableViewX: UITableView!
    @IBOutlet weak var totalPurchaseCount: UILabel!
    @IBOutlet weak var errorText: UILabel!
    @IBOutlet weak var receiptCreationDate: UILabel!
    @IBOutlet weak var bundleVersion: UILabel!
    @IBOutlet weak var bundleIdentifier: UILabel!
    @IBOutlet weak var receiptExpireDate: UILabel!
    
    var purchases: [PurchaseData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewX.delegate = self
        tableViewX.dataSource = self
        let nib = UINib(nibName: "PurchaseItem", bundle: nil)
        tableViewX.register(nib, forCellReuseIdentifier: "PurchaseItem")
        errorText.text = ""
        showReceiptData()
        // Do any additional setup after loading the view.
    }
    
    func showReceiptData() {
        if let receiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: receiptURL.path) {
            let receiptData = try? Data(contentsOf: receiptURL, options: .alwaysMapped)
            do {
                let appleContainer = try AppleContainer(data: receiptData!)
                let receiptData = try appleContainer.AppleReceipt()
                bundleIdentifier.text = receiptData.bundleIdentifier
                bundleVersion.text = receiptData.bundleVersion
                receiptCreationDate.text = receiptData.creationDateString
                receiptExpireDate.text = receiptData.expirationDateString
                guard let purchase = receiptData.purchases else { return }
                totalPurchaseCount.text = "\(String(describing: purchase.count))"
                purchases = receiptData.purchases!
                DispatchQueue.main.async {
                    self.tableViewX.reloadData()
                }
                
                // Initailly we need to validate the receipt first
//                try receiptData.isValidReceipt()
//                dump(receiptData)
//
//                print(receiptData.containsPurchase(ofProductIdentifier: "com.bjitgroup.easypurchase.nonRenewable.twenty"))
//                let x = try receiptData.isNonRenewableActive(productIdentifier: "com.bjitgroup.easypurchase.nonRenewable.twenty", validForDay: 20)
////                let y = try receiptData.isNonRenewableActive(productIdentifier: "com.bjitgroup.easypurchase.autorenewyearly", validForDay: 20)
////                print(receiptData.isNonRenewHasExpired(productIdentifier: "com.bjitgroup.easypurchase.nonRenewable.twenty", validForday: 1))
//                let z = try receiptData.isNonRenewableActive(productIdentifier: "com.bjitgroup.easypurchase.nonconsumable.levelthree", validForDay: 20)
//                print(z)
//                let z2 = try receiptData.isNonRenewableActive(productIdentifier: "com.bjitgroup.easypurchase.nonconsumable.levelthree", validForDay: 1)
//                print(z2)
            } catch {
                errorText.text = "Error Occured during parsing receipt data"
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ReceiptData: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        purchases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableViewX.dequeueReusableCell(withIdentifier: "PurchaseItem", for: indexPath) as? PurchaseItem else {
            return UITableViewCell()
        }
        cell.view.layer.cornerRadius = 10
        cell.productID.text = purchases[indexPath.row].productIdentifier
        cell.Quantity.text = String("\(purchases[indexPath.row].quantities)")
        cell.purchaseDate.text = (purchases[indexPath.row].purchaseDate)?.description
        cell.expireDate.text = (purchases[indexPath.row].expiresDate)?.description
        cell.cancellationDate.text = (purchases[indexPath.row].cancellationDate)?.description
        return cell
    }
    
    
}
