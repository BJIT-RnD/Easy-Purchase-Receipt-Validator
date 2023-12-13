//
//  PurchaseItem.swift
//  Demo
//
//  Created by BJIT on 8/12/23.
//

import UIKit

class PurchaseItem: UITableViewCell {
    @IBOutlet weak var productID: UILabel!
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var cancellationDate: UILabel!
    @IBOutlet weak var expireDate: UILabel!
    @IBOutlet weak var purchaseDate: UILabel!
    @IBOutlet weak var quantity: UILabel!
}
