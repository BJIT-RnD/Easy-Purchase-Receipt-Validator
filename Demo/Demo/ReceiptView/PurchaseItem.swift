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
    @IBOutlet weak var Quantity: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
