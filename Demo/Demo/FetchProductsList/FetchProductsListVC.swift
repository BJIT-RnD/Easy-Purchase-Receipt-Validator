//
//  FetchProductsListVC.swift
//  Demo
//
//  Created by BJIT on 17/10/23.
//

import UIKit
import StoreKit

final class FetchProductsListVC: UIViewController {
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var tableViewX: UITableView!
    static var viewModel = FetchProductListViewModel()
    var productList = FetchList(consumable: [], nonConsumable: [], nonRenewable: [], autoRenewable: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        setupBinders()
        FetchProductsListVC.viewModel.getPurchasableProducts()
    }
    private func setupBinders() {
        FetchProductsListVC.viewModel.fetchList.bind { [weak self] fetchedList in
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
    private func initialSetup() {
        tableViewX.delegate = self
        tableViewX.dataSource = self
        let nib = UINib(nibName: "ProductCell", bundle: nil)
        tableViewX.register(nib, forCellReuseIdentifier: "ProductCell")
    }
    private func getProductType(section: Int) -> [SKProduct] {
        switch section {
        case 0:
            return productList.consumable
        case 1:
            return productList.nonConsumable
        case 2:
            return productList.nonRenewable
        default:
            return productList.autoRenewable
        }
    }
    private func getCellImage(section: Int) -> UIImage? {
        switch section {
        case 0:
            return UIImage(named: "consume")
        case 1:
            return UIImage(named: "level")
        case 2:
            return UIImage(named: "nonrenew")
        default:
            return UIImage(named: "autorenew")
        }
    }
}

extension FetchProductsListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 30 // Set the height of the header to 100 points
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        headerView.backgroundColor = .clear
        let headerLabel = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.width - 30, height: 20))
        if section == 0 {
            headerLabel.text = "Consumable"
        } else if section == 1 {
            headerLabel.text = "Non-Consumable"
        } else if section == 2 {
            headerLabel.text = "Non-Renewable"
        } else {
            headerLabel.text = "Auto-Renewable"
        }
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        headerLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.35, alpha: 0.76)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return productList.consumable.count
        case 1:
            return productList.nonConsumable.count
        case 2:
            return productList.nonRenewable.count
        case 3:
            return productList.autoRenewable.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableViewX.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell else {
            return UITableViewCell()
        }
        cell.view.layer.cornerRadius = 10
        cell.productImage.layer.cornerRadius = 10
        let products = getProductType(section: indexPath.section)
        cell.productTitle.text = products[indexPath.row].localizedTitle
        cell.productPrice.text = "$ \(products[indexPath.row].price)"
        cell.productImage.image = getCellImage(section: indexPath.section)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let products = getProductType(section: indexPath.section)
        FetchProductsListVC.viewModel.buyProduct(products[indexPath.row])
    }
}
