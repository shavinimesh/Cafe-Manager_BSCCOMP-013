//
//  FoodItemViewCell.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import UIKit
import Kingfisher

class FoodItemViewCell: UITableViewCell {

    @IBOutlet weak var lblFoodName: UILabel!
    @IBOutlet weak var lblFoodInfo: UILabel!
    @IBOutlet weak var lblFoodPrice: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var ViewContainerDiscount: UIView!
    @IBOutlet weak var imgFoodItem: UIImageView!
    @IBOutlet weak var switchIsActive: UISwitch!
    @IBOutlet weak var viewOfferContainer: UIView!
    
    var rowIndex: Int = 0
    var delegate: FoodItemCellActions?
    
    class var reuseIdentifier: String {
        return "FoodCellIdentifier"
    }
    
    class var nibName: String {
        return "FoodItemViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(foodItem: FoodItem) {
        lblFoodInfo.text = foodItem.foodDescription
        lblFoodName.text = foodItem.foodName
        imgFoodItem.kf.setImage(with: URL(string: foodItem.foodImgRes))
        lblFoodPrice.text = "RS. \(foodItem.foodPrice)"
        
        if foodItem.discount == 0
        {
            ViewContainerDiscount.isHidden = true
        }
        else
        {
            ViewContainerDiscount.isHidden = false
            lblDiscount.text = "\(foodItem.discount)% OFF"
        }
    }
    @IBAction func onFoodStatusChanged(_ sender: UISwitch) {
        self.delegate?.onFoodItemStatusChanged(status: sender.isOn, index: self.rowIndex)
    }
    
    func configureCell(foodItem: FoodItem, index: Int) {
        self.rowIndex = index
        if foodItem.discount == 0 {
            viewOfferContainer.isHidden = true
        } else {
            viewOfferContainer.isHidden = false
            lblDiscount.text = "\(foodItem.discount)% OFF"
        }
        
        switchIsActive.isOn = foodItem.isActive
        
        imgFoodItem.kf.setImage(with: URL(string: foodItem.foodImgRes))
        lblFoodName.text = foodItem.foodName
        lblFoodInfo.text = foodItem.foodDescription
        lblFoodPrice.text = "\(foodItem.discountedPrice.lkrString)"
    }
    
}

protocol FoodItemCellActions {
    func onFoodItemStatusChanged(status: Bool, index: Int)
}


