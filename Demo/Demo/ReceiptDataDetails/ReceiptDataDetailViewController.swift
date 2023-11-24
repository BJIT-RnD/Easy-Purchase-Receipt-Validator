//
//  ReceiptDataDetailViewController.swift
//  Demo
//
//  Created by BJIT on 23/11/23.
//

import UIKit
import Easy_Purchase_Receipt_Validator

class ReceiptDataDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var list: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        if let receiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: receiptURL.path) {
            let receiptData = try! Data(contentsOf: receiptURL, options: .alwaysMapped)
            do{
                let appleContainer = try AppleContainer(data: receiptData)
                let receiptData = appleContainer.AppleReceipt()

                list.append("Bundle Identifier: \(receiptData?.bundleIdentifier ?? "")")
                list.append("Original App Version: \(receiptData?.originalAppVersion ?? "")")
                list.append("Bundle Version: \(receiptData?.bundleVersion ?? "")")
                list.append("Bundle Identifier Data: \(String(describing: receiptData?.bundleIdentifierData))")
                list.append("Opaque Value: \(String(describing: receiptData?.opaqueValue))")
                list.append("Receipt Hash: \(String(describing: receiptData?.receiptHash))")
                list.append("Creation Date: \(String(describing: receiptData?.creationDate ?? Date()))")
                list.append("Expiration Date: \(String(describing: receiptData?.expirationDate ?? Date()))")
                list.append("Creation Date String: \(String(describing: receiptData?.creationDateString ?? ""))")
                list.append("Expiration Date String: \(String(describing: receiptData?.expirationDateString ?? ""))")


            } catch {

            }


        }
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension ReceiptDataDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = list[indexPath.row]

        return cell
    }
    

}
