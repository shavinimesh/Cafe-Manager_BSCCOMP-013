//
//  CategoryViewCell.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import UIKit

class CategoryViewCell: UICollectionViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblCategory: UILabel!
    
    class var reuseIdentifier: String {
        return "CategoryCellIdentifier"
    }
    
    class var nibName: String {
        return "CategoryViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configCell(category: FoodCategory) {
        lblCategory.text = category.categoryName
        if category.isSelected
        {
            viewContainer.backgroundColor = UIColor(named: "orange")
            lblCategory.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        else
        {
            viewContainer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            lblCategory.textColor = UIColor(named: "dark_gray")
        }
    }
}

