//
//  ProductDetailVC.swift
//  Demo
//
//  Created by BJIT on 17/10/23.
//

import UIKit
import StoreKit

final class ProductDetailVC: UIViewController {
    @IBOutlet weak var productImage: UIImageView!
    
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    var product: SKProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    private func initialSetup() {
        guard let product else {
            return
        }
        productTitle.text = product.localizedTitle
        productPrice.text = "$\(product.price)"
        productDescription.text = product.description
    }
}
