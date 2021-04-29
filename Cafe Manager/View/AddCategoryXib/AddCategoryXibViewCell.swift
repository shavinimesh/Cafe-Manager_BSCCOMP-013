//
//  AddCategoryXibTableViewCell.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import UIKit

class AddCategoryXibViewCell: UITableViewCell {
    @IBOutlet weak var lblCategory: UILabel!
    
    class var reuseIdentifier: String {
        return "AddCategoryReusableCell"
    }
    
    
    class var nibName: String {
        return "AddCategoryXibViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(category: FoodCategory) {
        lblCategory.text = category.categoryName
    
}
}
