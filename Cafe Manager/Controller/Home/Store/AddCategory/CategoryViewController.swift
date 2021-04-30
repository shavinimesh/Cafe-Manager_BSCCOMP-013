//
//  CategoryViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import UIKit

class CategoryViewController: BaseViewController {
    
    @IBOutlet weak var txtCategoryName: CustomTextField!
    @IBOutlet weak var tblCategories: UITableView!
    
    var categories: [FoodCategory] = []
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firebaseOP.delegate = self
        registerNIB()
        displayProgress()
        firebaseOP.fetchAllFoodItems(addDefault: false)
        
        if #available(iOS 10.0, *) {
            tblCategories.refreshControl = refreshControl
        } else {
            tblCategories.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshCategoryData), for: .valueChanged)
    }
    
    func registerNIB() {
        tblCategories.register(UINib(nibName: AddCategoryXibViewCell.nibName, bundle: nil), forCellReuseIdentifier: AddCategoryXibViewCell.reuseIdentifier)
    }
    
    @objc func refreshCategoryData() {
        firebaseOP.fetchAllFoodItems(addDefault: false)
    }

    @IBAction func onPressed(_ sender: UIButton) {
        if !InputFieldValidator.isValidName(txtCategoryName.text ?? "") {
            txtCategoryName.clearText()
            txtCategoryName.displayInlineError(errorString: InputErrorCaptions.invaliCategorydName)
            return
        }
        
        if categories.contains(where: {$0.categoryName == txtCategoryName.text!}) {
            displayErrorMessage(message: "The category already exists!")
            return
        }
        
        displayProgress()
        firebaseOP.addFoodCategory(categoryName: txtCategoryName.text!)
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblCategories.dequeueReusableCell(withIdentifier: AddCategoryXibViewCell.reuseIdentifier, for: indexPath) as! AddCategoryXibViewCell
        cell.selectionStyle = .none
        cell.configureCell(category: categories[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0.01 * Double(indexPath.row), usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1,
                       options: .curveEaseIn, animations: {
                        cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
                       })
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            displayProgress()
            firebaseOP.removeFoodCategory(categoryID: categories[indexPath.row].categoryID)
            categories.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension CategoryViewController : FirebaseActions {
    func onConnectionLost() {
        refreshControl.endRefreshing()
        dismissProgress()
        displayWarningMessage(message: "Please check internet connection")
    }
    func onCategoriesLoaded(categories: [FoodCategory]) {
        refreshControl.endRefreshing()
        dismissProgress()
        self.categories.removeAll()
        self.categories.append(contentsOf: categories)
        self.tblCategories.reloadData()
    }
    func onFoodItemsLoadFailed(error: String) {
        refreshControl.endRefreshing()
        dismissProgress()
        displayErrorMessage(message: error)
    }
    func onFoodCategoryAdded() {
        txtCategoryName.text = ""
        dismissProgress()
        displaySuccessMessage(message: "Category added!", completion: nil)
        self.refreshCategoryData()
    }
    func onFoodCategoryNotAdded() {
        dismissProgress()
        displayErrorMessage(message: "Category not added!")
    }
    func onFoodCategoryRemoved() {
        dismissProgress()
        displaySuccessMessage(message: "Category removed!", completion: nil)
    }
    func onFoodCategoryNotRemoved() {
        dismissProgress()
        displayErrorMessage(message: "Category not removed!")
    }
}
