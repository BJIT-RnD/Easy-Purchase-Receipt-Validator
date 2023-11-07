//
//  RestoreVC.swift
//  Demo
//
//  Created by BJIT on 17/10/23.
//

import UIKit
import StoreKit

final class RestoreVC: UIViewController {
    @IBOutlet weak var tableViewX: UITableView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    static var viewModel = RestoreViewModel()
    var productList: [SKPaymentTransaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupBinder()
        // Do any additional setup after loading the view.
    }
    private func initialSetup() {
        tableViewX.delegate = self
        tableViewX.dataSource = self

        let nib = UINib(nibName: "ProductCell", bundle: nil)
        tableViewX.register(nib, forCellReuseIdentifier: "ProductCell")
    }
    private func setupBinder() {
        RestoreVC.viewModel.fetchList.bind { [weak self] fetchedList in
            DispatchQueue.main.async {
                self?.loader.stopAnimating()
            }
            guard let fetchedList = fetchedList else {
                return
            }
            self?.productList = fetchedList
            DispatchQueue.main.async { [weak self] in
                self?.tableViewX.reloadData()
            }
        }
    }

    @IBAction func restoreClicked(_ sender: Any) {
        loader.startAnimating()
        RestoreVC.viewModel.restoreCompletedTransactions()
    }
}

extension RestoreVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableViewX.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UITableViewCell()
        }
        cell.view.layer.cornerRadius = 10
        cell.productImage.layer.cornerRadius = 10
        guard let product = Constants.availableProductsCollection[productList[indexPath.row].payment.productIdentifier] else {
            return cell
        }
        cell.productTitle.text = product.localizedTitle
        cell.productPrice.text = "$\(product.price)"
        cell.productImage.image = UIImage(named: "unlocked")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewX.deselectRow(at: indexPath, animated: true)
        if let destinationVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as? ProductDetailVC {
            destinationVC.hidesBottomBarWhenPushed = true
            guard let product = Constants.availableProductsCollection[productList[indexPath.row].payment.productIdentifier] else {
                return
            }
            destinationVC.product = product
            navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
}
