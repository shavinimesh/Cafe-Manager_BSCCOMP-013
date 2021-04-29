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
    
    }
    

