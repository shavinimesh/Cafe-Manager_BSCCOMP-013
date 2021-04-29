//
//  FoodViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import UIKit

class FoodViewController: BaseViewController {

    @IBOutlet weak var tblFoodItems: UITableView!
    @IBOutlet weak var collectionViewCategories: UICollectionView!
    
    var selectedCategoryIndex: Int = 0
    var selectedFoodIndex: Int = 0
    
    var categories: [FoodCategory] = []
    var foodItemList: [FoodItem] = []
    
    var filteredFood: [FoodItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let nib = UINib(nibName: "FoodItemViewCell", bundle: nil)
        tblFoodItems.register(UINib(nibName: FoodItemViewCell.nibName, bundle: nil), forCellReuseIdentifier: FoodItemViewCell.reuseIdentifier)
        collectionViewCategories.register(UINib(nibName: CategoryViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: CategoryViewCell.reuseIdentifier)
        if let flowLayout = self.collectionViewCategories?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 100, height: 30)
        }
        
        super.viewDidLoad()
        networkMonitor.delegate = self
        firebaseOP.delegate = self
        firebaseOP.fetchAllFoodItems()
        displayProgress()
    }
    
   // override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //    if segue.identifier == "FoodDetailsViewController" {
    //        let destVC = segue.destination as! FoodDetailsViewController
     //       destVC.foodItem = filteredFood[selectedFoodIndex]
       // }
   // }
    
    override func viewDidAppear(_ animated: Bool) {
        firebaseOP.delegate = self
        networkMonitor.delegate = self
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension FoodViewController {
    func filterFood(foodCategory: String) {
        filteredFood.removeAll()
        filteredFood = foodItemList.filter { $0.foodCategory == foodCategory }
        tblFoodItems.reloadData()
    }
    
    func displayAllFood() {
        filteredFood.removeAll()
        filteredFood.append(contentsOf: foodItemList)
        tblFoodItems.reloadData()
    }
}

//UITableView Protocols

extension FoodViewController : UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionViewCategories.dequeueReusableCell(withReuseIdentifier: CategoryViewCell.reuseIdentifier,
                                                                   for: indexPath) as? CategoryViewCell {
            cell.configCell(category: categories[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        categories[selectedCategoryIndex].isSelected = false
        selectedCategoryIndex = indexPath.row
        categories[indexPath.row].isSelected = true
        UIView.transition(with: collectionViewCategories, duration: 0.3, options: .transitionCrossDissolve, animations: {self.collectionViewCategories.reloadData()}, completion: nil)
        
        if indexPath.row == 0 {
            displayAllFood()
            return
        }
        
        filterFood(foodCategory: categories[indexPath.row].categoryName)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell: CategoryViewCell = Bundle.main.loadNibNamed(CategoryViewCell.nibName,
                                                                owner: self,
                                                                options: nil)?.first as? CategoryViewCell else {
            return CGSize.zero
        }
        cell.configCell(category: categories[indexPath.row])
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let size: CGSize = cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(width: size.width, height: 30)
    }
}


extension FoodViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFood.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblFoodItems.dequeueReusableCell(withIdentifier: FoodItemViewCell.reuseIdentifier, for: indexPath) as! FoodItemViewCell
        cell.selectionStyle = .none
        cell.configCell(foodItem: filteredFood[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFoodIndex = indexPath.row
        self.performSegue(withIdentifier: "FoodDetailsViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0.01 * Double(indexPath.row), usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1,
                       options: .curveEaseIn, animations: {
                        cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
                       })
    }
}

extension FoodViewController : FirebaseActions {
    func onCategoriesLoaded(categories: [FoodCategory]) {
        refreshControl.endRefreshing()
        dismissProgress()
        self.categories.removeAll()
        self.categories.append(contentsOf: categories)
        self.collectionViewCategories.reloadData()
    }
    func onFoodItemsLoaded(foodItems: [FoodItem]) {
        refreshControl.endRefreshing()
        dismissProgress()
        foodItemList.removeAll()
        filteredFood.removeAll()
        self.foodItemList.append(contentsOf: foodItems)
        self.filteredFood.append(contentsOf: foodItemList)
        self.tblFoodItems.reloadData()
    }
    func onFoodItemsLoadFailed(error: String) {
        refreshControl.endRefreshing()
        dismissProgress()
        displayErrorMessage(message: error)
    }
}
