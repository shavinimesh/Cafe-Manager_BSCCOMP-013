//
//  FoodViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import UIKit
import Lottie

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
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firebaseOP.delegate = self
        registerNIB()
        
        if #available(iOS 10.0, *) {
            tblFoodItems.refreshControl = refreshControl
        } else {
            tblFoodItems.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshFoodData), for: .valueChanged)
//        displayProgress()
       // displayAnimation()
        firebaseOP.fetchAllFoodItems()
    }
    
    func registerNIB() {
        let collectionViewNib = UINib(nibName: CategoryViewCell.nibName, bundle: nil)
        collectionViewCategories.register(collectionViewNib, forCellWithReuseIdentifier: CategoryViewCell.reuseIdentifier)
        if let flowLayout = self.collectionViewCategories?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 80, height: 30)
        }
        tblFoodItems.register(UINib(nibName: FoodItemViewCell.nibName, bundle: nil), forCellReuseIdentifier: FoodItemViewCell.reuseIdentifier)
    }
    
    @objc func refreshFoodData() {
//        displayProgress()
      //  displayAnimation()
        firebaseOP.fetchAllFoodItems()
    }
    
   /* func displayAnimation() {
        animationViewFood.loopMode = .loop
        animationViewFood.isHidden = false
        animationViewFood.play()
    }
    
    func dismissAnimation() {
        animationViewFood.stop()
        animationViewFood.isHidden = true
    }*/

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
        
        filterFood(foodCategory: categories[indexPath.row].categoryID)
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

extension FoodViewController: FoodItemCellActions {
    func onFoodItemStatusChanged(status: Bool, index: Int) {
        displayProgress()
        firebaseOP.changeFoodStatus(status: status, foodItem: foodItemList[index], index: index)
    }
}

extension FoodViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFood.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblFoodItems.dequeueReusableCell(withIdentifier: FoodItemViewCell.reuseIdentifier, for: indexPath) as! FoodItemViewCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.configureCell(foodItem: filteredFood[indexPath.row], index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFoodIndex = indexPath.row
//        self.performSegue(withIdentifier: StoryBoardSegues.homeToViewDetails, sender: nil)
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
    func onConnectionLost() {
        refreshControl.endRefreshing()
//        dismissProgress()
     //   dismissAnimation()
        displayWarningMessage(message: "Please check internet connection")
    }
    func onCategoriesLoaded(categories: [FoodCategory]) {
        NSLog("Categories Loaded")
        refreshControl.endRefreshing()
//        dismissProgress()
      //  dismissAnimation()
        self.categories.removeAll()
        self.categories.append(contentsOf: categories)
        self.collectionViewCategories.reloadData()
    }
    func onFoodItemsLoaded(foodItems: [FoodItem]) {
        NSLog("Food Items Loaded")
        refreshControl.endRefreshing()
        //        dismissProgress()
    //    dismissAnimation()
        foodItemList.removeAll()
        filteredFood.removeAll()
        self.foodItemList.append(contentsOf: foodItems)
        self.filteredFood.append(contentsOf: foodItemList)
        self.tblFoodItems.reloadData()
    }
    func onFoodItemsLoadFailed(error: String) {
        refreshControl.endRefreshing()
        //        dismissProgress()
    //    dismissAnimation()
        displayErrorMessage(message: error)
    }
    func onFoodItemStatusChanged(index: Int, status: Bool) {
        self.foodItemList[index].isActive = status
        self.filteredFood[index].isActive = status
        dismissProgress()
        displaySuccessMessage(message: "Status Changed", completion: nil)
        tblFoodItems.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    func onFoodItemStatusNotChanged(index: Int) {
        tblFoodItems.reloadData()
        dismissProgress()
        displayErrorMessage(message: "Could not change status")
    }
}

