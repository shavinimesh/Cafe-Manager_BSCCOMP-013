//
//  MenuViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import UIKit

class MenuViewController: BaseViewController {

    @IBOutlet weak var txtItemName: CustomTextField!
    @IBOutlet weak var txtDescription: CustomTextField!
    @IBOutlet weak var txtItemPrice: CustomTextField!
    @IBOutlet weak var txtItemCategory: CustomTextField!
    @IBOutlet weak var txtItemDiscount: CustomTextField!
    @IBOutlet weak var switchSellAsItem: UISwitch!
    @IBOutlet weak var imgFood: UIImageView!
    
    var imagePicker: ImagePicker!
    var selectedImage: UIImage?
    
    var foodItem: FoodItem?
    
    var categoryPicker = UIPickerView()
    
    var categories: [FoodCategory] = []
    var foodItemList: [FoodItem] = []
    var selectedCategoryIndex = 0
    var categoryString: [String] {
        return categories.map{$0.categoryName}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        
//        let categoryString = categories.map{$0.categoryName}
                
        //set tap gesture for the UIImageView [UserInteraction should be enabled]
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onPickImageClicked))
        self.imgFood.isUserInteractionEnabled = true
        self.imgFood.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firebaseOP.delegate = self
        firebaseOP.fetchAllFoodItems(addDefault: false)
    }
    
    //Open imagepicker menu
    @objc func onPickImageClicked(_ sender: UIImageView){
        self.imagePicker.present(from: sender)
    }

    @IBAction func onAddPresed(_ sender: UIButton) {if !InputFieldValidator.isValidName(txtItemName.text ?? "") {
        txtItemName.clearText()
        txtItemName.displayInlineError(errorString: InputErrorCaptions.invalidFoodName)
        return
    }
    if !InputFieldValidator.isValidDescription(txtDescription.text ?? "") {
        txtDescription.clearText()
        txtDescription.displayInlineError(errorString: InputErrorCaptions.invalidFoodDescription)
        return
    }
    if !InputFieldValidator.isValidPrice(txtItemPrice.text ?? "") {
        txtItemPrice.clearText()
        txtItemPrice.displayInlineError(errorString: InputErrorCaptions.invalidFoodPrice)
        return
    }
    if !InputFieldValidator.isNotEmptyOrNil(txtItemCategory.text) {
        txtItemCategory.clearText()
        displayInfoMessage(message: "Select a category!")
        return
    }
    if !InputFieldValidator.isValidDiscount(txtItemDiscount.text ?? "") {
        txtItemDiscount.clearText()
        txtItemDiscount.displayInlineError(errorString: InputErrorCaptions.invalidDiscount)
        return
    }
    
    if selectedImage == nil {
        displayInfoMessage(message: "Please select an image!")
        return
    }
    
    if foodItemList.contains(where: {$0.foodName == txtItemName.text!}) {
        displayErrorMessage(message: "The food already exists!")
        return
        
    }
    
    self.foodItem = FoodItem(foodName: txtItemName.text!,
                             foodDescription: txtDescription.text!,
                             foodPrice: Double(txtItemPrice.text!) ?? 0,
                             discount: Int(txtItemDiscount.text!) ?? 0,
                             foodImgRes: "",
                             foodCategory: categories[selectedCategoryIndex].categoryID,
                             isActive: true)
   // displayProgressBanner()
    firebaseOP.addFoodItem(foodItem: foodItem!, image: selectedImage!)
}
}

extension MenuViewController: UIPickerViewDataSource, UIPickerViewDelegate {
func setupCategoryPicker() {
    let pickerToolBar = UIToolbar()
    pickerToolBar.sizeToFit()
    
//        let doneAction = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onValuePicked))
    let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(onPickerCancelled))
    let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    pickerToolBar.setItems([space, cancelButton], animated: true)
    
    txtItemCategory.inputAccessoryView = pickerToolBar
    txtItemCategory.inputView = categoryPicker
    categoryPicker.delegate = self
    categoryPicker.dataSource = self
}

@objc func onPickerCancelled() {
    self.view.endEditing(true)
}

func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
}

func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categories.count
}

func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return categoryString[row]
}

func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    txtItemCategory.text = categoryString[row]
    selectedCategoryIndex = row
}
}

extension MenuViewController: ImagePickerDelegate {
func didSelect(image: UIImage?) {
    self.imgFood.image = image
    self.selectedImage = image
    
    if image == nil {
        self.imgFood.image = UIImage(systemName: "photo.fill")
    }
}
}

extension MenuViewController: FirebaseActions {
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
    setupCategoryPicker()
}
func onFoodItemsLoaded(foodItems: [FoodItem]) {
    NSLog("Food Items Loaded")
    refreshControl.endRefreshing()
    dismissProgress()
    foodItemList.removeAll()
    self.foodItemList.append(contentsOf: foodItems)
}
func onFoodItemsLoadFailed(error: String) {
    refreshControl.endRefreshing()
    dismissProgress()
    displayErrorMessage(message: error)
}
func onFoodItemAdded() {
    dismissProgress()
    displaySuccessMessage(message: "Food item added!", completion: nil)
    txtItemName.text = ""
    txtDescription.text = ""
    txtItemPrice.text = ""
    txtItemDiscount.text = ""
    self.imgFood.image = UIImage(systemName: "photo.fill")
    self.selectedImage = nil
}
func onFoodItemNotAdded() {
    dismissProgress()
    displayErrorMessage(message: "Food item not added!")
}

}
