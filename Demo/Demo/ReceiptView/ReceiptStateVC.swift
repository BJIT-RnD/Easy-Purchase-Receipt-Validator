//
//  ReceiptStateVC.swift
//  Demo
//
//  Created by BJIT on 18/10/23.
//

import UIKit

final class ReceiptStateVC: UIViewController {
    @IBOutlet weak var availabilityBox: UIView!
    @IBOutlet weak var availabilityLabel: UILabel!
    var doesReceiptExist = false
    static var viewModel = ReceiptStateViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupBinders()
    }
    private func initialSetup() {
        availabilityBox.layer.cornerRadius = 10
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        doesReceiptExist = ReceiptStateVC.viewModel.doesAppStoreReceiptExist()
    }
    private func setupBinders() {
        ReceiptStateVC.viewModel.isReceiptAvailable.bind { [weak self] value in
            if value ?? false {
                UIView.animate(withDuration: 1.0) {
                    self?.availabilityBox.backgroundColor = UIColor(red: 0, green: 0.45, blue: 0.13, alpha: 1)
                }
                self?.availabilityLabel.text = "Available"
            }
        }
    }
}
