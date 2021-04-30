//
//  OrderItemInfoTableViewCell.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-30.
//

import UIKit

class OrderItemInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblQTY: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblFoodDescription: UILabel!
    
    class var reuseIdentifier: String {
        return "orderItemInfoReuseIdentifier"
    }
    
    class var nibName: String {
        return "OrderItemInfoTableViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(qty: Int, foodDescription: String, price: String) {
        lblQTY.text = "\(qty) X"
        lblFoodDescription.text = foodDescription
        lblPrice.text = price
    }
    
}
