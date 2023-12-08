//
//  ReceiptStateVC.swift
//  Demo
//
//  Created by BJIT on 18/10/23.
//

import UIKit

final class ReceiptStateVC: UIViewController {
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var availabilityBox: UIView!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var receiptPageOutlet: UIButton!
    var doesReceiptExist = false
    static var viewModel = ReceiptStateViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupBinders()
    }
    private func initialSetup() {
        availabilityBox.layer.cornerRadius = 10
        refreshBtn.layer.cornerRadius = 10
        receiptPageOutlet.layer.cornerRadius = 10
        receiptPageOutlet.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doesReceiptExist = ReceiptStateVC.viewModel.doesAppStoreReceiptExist()
    }
    private func setupBinders() {
        ReceiptStateVC.viewModel.isReceiptAvailable.bind { [weak self] value in
            self?.loader.stopAnimating()
            if value ?? false {
                UIView.animate(withDuration: 1.0) {
                    self?.availabilityBox.backgroundColor = UIColor(red: 0, green: 0.45, blue: 0.13, alpha: 1)
                }
                self?.availabilityLabel.text = "Available"
                self?.receiptPageOutlet.isHidden = false
            }
        }
    }
    @IBAction func receiptPageAction(_ sender: Any) {
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "ReceiptData") as? ReceiptData {
            destinationVC.hidesBottomBarWhenPushed = true
//            guard let product = Constants.availableProductsCollection[productList[indexPath.row].payment.productIdentifier] else {
//                return
//            }
//            destinationVC.product = product
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    @IBAction func refreshReceipt(_ sender: Any) {
        loader.startAnimating()
        ReceiptStateVC.viewModel.refreshReceipt()
    }
}
