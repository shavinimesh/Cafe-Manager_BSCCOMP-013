//
//  FirebaseOP.swift
//  CafeManager
//
//  Created by Hishara Dilshan on 2021-04-28.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import CoreLocation

class FirebaseOP {
    //Class instance
    static var instance = FirebaseOP()
    
    var dbRef: DatabaseReference!
    let networkChecker = NetworkMonitor.instance
    
    //Class Delegate
    var delegate: FirebaseActions?
    
    //Make Singleton
    fileprivate init() {}
    
    func checkConnection() -> Bool {
        if !networkChecker.isReachable {
            delegate?.onConnectionLost()
            return false
        }
        return true
    }
    
    private func getDBReference() -> DatabaseReference {
        guard dbRef != nil else {
            dbRef = Database.database().reference()
            return dbRef
        }
        return dbRef
    }
    
    fileprivate func getStorageReference() -> StorageReference {
        return Storage.storage().reference()
    }
    
    // MARK: - User Based Operations
    
    fileprivate func checkExistingUser(email: String, completion: @escaping (Bool, String, DataSnapshot) -> Void) {
        if !checkConnection() {
            return
        }
        let email = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        self.getDBReference().child("users").child(email).observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChildren() {
                if let userData = snapshot.value as? [String: Any] {
                    if userData[UserKeys.type] as? String != "manager" {
                        completion(false, "User does not exists", snapshot)
                        return
                    }
                }
                completion(true, "User already exists.", snapshot)
            } else {
                completion(false, "User does not exists", snapshot)
            }
        })
    }
    
    fileprivate func setUpAuthenticationAccount(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
        if !checkConnection() {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: {
            result, error in
            if let error = error {
                NSLog(error.localizedDescription)
                NSLog("Creation of authentication account failed")
                completion(false, "Could not create user account")
            } else {
                completion(true, "Created authentication account")
                NSLog(result?.description ?? "")
            }
        })
    }
    
    fileprivate func createUserOnDB(user: User, completion: @escaping (Bool, String?, User?) -> Void) {
        if !checkConnection() {
            return
        }
        guard let userName = user.userName, let email = user.email, let phoneNo = user.phoneNo else {
            NSLog("Empty params found on user instance")
            completion(false, "Empty params found on user instance", user)
            return
        }
        
        let data = [
            UserKeys.userName : userName,
            UserKeys.email : email,
            UserKeys.phoneNo : phoneNo,
            UserKeys.type : "manager"
        ]
        
        self.getDBReference()
            .child("users")
            .child(email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_"))
            .setValue(data) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    completion(false, "Failed to create user", user)
                    NSLog(error.localizedDescription)
                } else {
                    completion(true, nil, user)
                }
            }
    }
    
    func registerUser(user: User) {
        if !checkConnection() {
            return
        }
        guard let email = user.email, let password = user.password else {
            NSLog("Empty params found on user instance")
            self.delegate?.isSignUpFailedWithError(error: FieldErrorCaptions.userRegistrationFailedError)
            return
        }
        
        self.checkExistingUser(email: email, completion: {
            userExistance, result, data in
            if userExistance {
                self.delegate?.isExisitingUser(error: FieldErrorCaptions.userAlreadyExistsError)
                return
            }
            
            self.setUpAuthenticationAccount(email: email, password: password, completion: {
                authOperation, result in
                
                if !authOperation {
                    self.delegate?.isSignUpFailedWithError(error: FieldErrorCaptions.userRegistrationFailedError)
                    return
                }
                
                self.createUserOnDB(user: user, completion: {
                    userCreation, result, user in
                    
                    if userCreation {
                        self.delegate?.isSignUpSuccessful(user: user)
                    } else {
                        self.delegate?.isSignUpFailedWithError(error: FieldErrorCaptions.userRegistrationFailedError)
                    }
                })
            })
        })
    }
    
    func signInUser(email: String, password: String) {
        if !checkConnection() {
            return
        }
        self.checkExistingUser(email: email, completion: {
            userExistance, result, data in
            
            if userExistance {
                
                Auth.auth().signIn(withEmail: email, password: password, completion: {
                    authResult, error in
                    
                    if let error = error {
                        self.delegate?.onUserSignInFailedWithError(error: error.localizedDescription)
                        NSLog(error.localizedDescription)
                    } else {
                        if let userData = data.value as? [String: Any] {
                            NSLog("Successful sign-in")
                            self.delegate?.onUserSignInSuccess(user: User(
                                                                _id: nil,
                                                                userName: userData[UserKeys.userName] as? String,
                                                                email: userData[UserKeys.email] as? String,
                                                                phoneNo: userData[UserKeys.phoneNo] as? String,
                                                                password: userData[UserKeys.password] as? String, imageRes: ""))
                        } else {
                            NSLog("Unable to serialize user data")
                            self.delegate?.onUserSignInFailedWithError(error: FieldErrorCaptions.userSignInFailedError)
                        }
                    }
                })
            } else {
                NSLog("User not registered")
                self.delegate?.onUserSignInFailedWithError(error: FieldErrorCaptions.userNotRegisteredError)
            }
        })
    }
    
    func sendResetPasswordRequest(email: String) {
        if !checkConnection() {
            return
        }
        self.checkExistingUser(email: email, completion: {
            userExistance, result, data in
            
            if !userExistance {
                self.delegate?.onResetPasswordEmailSentFailed(error: FieldErrorCaptions.userNotRegisteredError)
                return
            }
            
            Auth.auth().sendPasswordReset(withEmail: email, completion: {
                error in
                
                if let error = error {
                    NSLog(error.localizedDescription)
                    self.delegate?.onResetPasswordEmailSentFailed(error: FieldErrorCaptions.userResetPasswordFailed)
                    return
                }
                
                self.delegate?.onResetPasswordEmailSent()
            })
            
        })
    }
    
    func fetchAllFoodItems(addDefault: Bool = true) {
        self.getDBReference().child("food_category").observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChildren() {
                
                var categoryList: [FoodCategory] = []
                var foodItemsList: [FoodItem] = []
                
                if addDefault {
                    categoryList.append(FoodCategory(categoryID: "All", categoryName: "All", isSelected: true))
                }
                
                if let data = snapshot.value as? [String: Any] {
                    for category in data {
                        guard let singleCategory = category.value as? [String: Any] else {
                            NSLog("Could not serialize inner data : singleCategory")
                            continue
                        }
                        categoryList.append(FoodCategory(categoryID: category.key, categoryName: singleCategory[FoodKeys.categoryName] as! String, isSelected: false))
                        if let foodItems = singleCategory[FoodKeys.food_items] as? [String : Any] {
                            for foodItem in foodItems {
                                guard let singleFoodItem = foodItem.value as? [String: Any] else {
                                    NSLog("Could not serialize inner data : foodItems in loop")
                                    continue
                                }
                                
                                foodItemsList.append(FoodItem(
                                                        foodItemID: foodItem.key,
                                                        foodName: singleFoodItem[FoodKeys.foodName] as! String,
                                                        foodDescription: singleFoodItem[FoodKeys.foodDescription] as! String,
                                                        foodPrice: singleFoodItem[FoodKeys.foodPrice] as! Double,
                                                        discount: singleFoodItem[FoodKeys.discount] as! Int,
                                                        foodImgRes: singleFoodItem[FoodKeys.foodImgRes] as! String,
                                                        foodCategory: category.key,
                                                        isActive: singleFoodItem[FoodKeys.isActive] as? Bool ?? true))
                            }
                        } else {
                            NSLog("Could not serialize inner data : foodItems")
//                            self.delegate?.onFoodItemsLoadFailed(error: FieldErrorCaptions.foodDataLoadFailed)
                        }
                    }
                    self.delegate?.onCategoriesLoaded(categories: categoryList)
                    self.delegate?.onFoodItemsLoaded(foodItems: foodItemsList.sorted { $0.foodName < $1.foodName })
                } else {
                    NSLog("Could not serialize data")
                    self.delegate?.onFoodItemsLoadFailed(error: FieldErrorCaptions.foodDataLoadFailed)
                }
            } else {
                NSLog("No food data found")
                self.delegate?.onFoodItemsLoadFailed(error: FieldErrorCaptions.noFoodItems)
            }
        })
    }
    
    func changeFoodStatus(status: Bool, foodItem: FoodItem, index: Int) {
        if !checkConnection() {
            return
        }
        self.getDBReference()
            .child("food_category")
            .child(foodItem.foodCategory)
            .child("food_items")
            .child(foodItem.foodItemID)
            .child("isActive")
            .setValue(status) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    self.delegate?.onFoodItemStatusNotChanged(index: index)
                    NSLog(error.localizedDescription)
                } else {
                    self.delegate?.onFoodItemStatusChanged(index: index, status: status)
                }
            }
    }
    
    func addFoodCategory(categoryName: String) {
        if !checkConnection() {
            return
        }
        self.getDBReference()
            .child("food_category")
            .childByAutoId()
            .child(FoodKeys.categoryName)
            .setValue(categoryName) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    self.delegate?.onFoodCategoryNotAdded()
                    NSLog(error.localizedDescription)
                } else {
                    self.delegate?.onFoodCategoryAdded()
                }
            }
        
    }
    
    func removeFoodCategory(categoryID: String) {
        self.getDBReference()
            .child("food_category")
            .child(categoryID)
            .removeValue() {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    self.delegate?.onFoodCategoryNotRemoved()
                    NSLog(error.localizedDescription)
                } else {
                    self.delegate?.onFoodCategoryRemoved()
                }
            }
    }
    
    func addFoodItem(foodItem: FoodItem, image: UIImage) {
        if !checkConnection() {
            return
        }
        if let uploadData = image.jpegData(compressionQuality: 0.5) {
            
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            
            getStorageReference().child("foodItemImages").child(foodItem.foodName).putData(uploadData, metadata: metaData) {
                meta, error in
                
                if let error = error {
                    NSLog("Unable to complete upload, Error : " + error.localizedDescription)
                    self.delegate?.onFoodItemNotAdded()
                    return
                }
                
                self.getStorageReference().child("foodItemImages").child(foodItem.foodName).downloadURL(completion: {
                    (url,error) in
                    guard let downloadURL = url else {
                        if let error = error {
                            NSLog("Unable to get download URL, Error : " + error.localizedDescription)
                        }
                        self.delegate?.onFoodItemNotAdded()
                        return
                    }
                    
                    let data = [
                        FoodKeys.foodName : foodItem.foodName,
                        FoodKeys.foodDescription : foodItem.foodDescription,
                        FoodKeys.foodPrice : foodItem.foodPrice,
                        FoodKeys.discount : foodItem.discount,
                        FoodKeys.foodImgRes : downloadURL.absoluteString,
                        FoodKeys.categoryName : foodItem.foodCategory,
                        FoodKeys.isActive : true
                    ] as [String : Any]
                    
                    
                    self.getDBReference()
                        .child("food_category")
                        .child(foodItem.foodCategory)
                        .child("food_items")
                        .childByAutoId()
                        .setValue(data) {
                            (error:Error?, ref:DatabaseReference) in
                            if let error = error {
                                self.delegate?.onFoodItemNotAdded()
                                NSLog(error.localizedDescription)
                            } else {
                                self.delegate?.onFoodItemAdded()
                            }
                        }
                })
            }
        }
    }
    
    func getAllOrders() {
        self.getDBReference().child("orders")
            .observeSingleEvent(of: .value, with: {
                snapshot in
                if snapshot.hasChildren() {
                    var orderedList: [Order] = []
                    if let data = snapshot.value as? [String: Any] {
                        for singleOrder in data {
                            guard let orderData = singleOrder.value as? [String: Any] else {
                                NSLog("Could not serialize inner data : singleOrder")
                                continue
                            }
                            print(orderData.keys)
                            var order = Order()
                            order.orderID = singleOrder.key
                            order.itemCount = orderData[OrderKeys.itemCount] as! Int
                            order.orderDate = Date().getDateFromMills(dateInMills: orderData[OrderKeys.orderDate] as! Int64)
                            order.orderStatusCode = orderData[OrderKeys.orderStatusCode] as! Int
                            order.orderStatusString = orderData[OrderKeys.orderStatusString] as! String
                            order.orderTotal = orderData[OrderKeys.orderTotal] as! Double
                            order.customername = orderData[OrderKeys.customerName] as! String
                            if let foodItems = orderData[OrderKeys.orderItems] as? NSArray {
                                var orderItems: [OrderItem] = []
                                for i in 0..<foodItems.count {
                                    guard let foodItem = foodItems[i] as? [String : Any] else {
                                        NSLog("Could not serialize inner data : foodItems in array")
                                        continue
                                    }
                                    orderItems.append(OrderItem(foodItem: FoodItem(foodName: foodItem[FoodKeys.foodName] as! String,
                                                                                    foodDescription: "",
                                                                                    foodPrice: foodItem[FoodKeys.foodPrice] as! Double,
                                                                                    discount: 0,
                                                                                    foodImgRes: "",
                                                                                    isActive: true),
                                                                 qty: foodItem[OrderKeys.itemCount] as! Int))
                                }
                                
                                
//                                for foodItem in foodItems {
//                                    guard let singleFoodItem = foodItem.value as? [String: Any] else {
//                                        NSLog("Could not serialize inner data : foodItems in loop")
//                                        continue
//                                    }
//                                    orderItems.append(OrderItem(foodItem: FoodItem(foodName: singleFoodItem[FoodKeys.foodName] as! String,
//                                                                                    foodDescription: "",
//                                                                                    foodPrice: singleFoodItem[FoodKeys.foodPrice] as! Double,
//                                                                                    discount: 0,
//                                                                                    foodImgRes: ""),
//                                                                 qty: singleFoodItem[OrderKeys.itemCount] as! Int))
                                    order.orderItems = orderItems
                                } else {
                                NSLog("Could not serialize order item")
                            }
                            orderedList.append(order)
                        }
                        orderedList = orderedList.sorted{ $0.orderDate > $1.orderDate }
                        self.delegate?.onAllOrdersLoaded(orderedList: orderedList)
                    } else {
                        NSLog("Unable to parse Order data")
                        self.delegate?.onAllOrdersLoadFailed(error: FieldErrorCaptions.orderLoadFailed)
                    }
                    
                } else {
                    NSLog("No orders found!")
                    self.delegate?.onAllOrdersLoadFailed(error: FieldErrorCaptions.noOrdersFound)
                }
            })
    }
    
    func changeOrderStatus(order: Order, status: Int) {
        self.getDBReference()
            .child("orders")
            .child(order.orderID)
            .child(OrderKeys.orderStatusCode)
            .setValue(status) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    self.delegate?.onOrderStatusNotChanged()
                    NSLog(error.localizedDescription)
                } else {
                    self.delegate?.onOrderStatusChanged(status: status)
                }
            }
    }
    
    func getUserLocationUpdates(order: Order) {
        self.getDBReference().child("orders")
            .child(order.orderID)
            .observe(.childChanged, with: {
                snapshot in
                if snapshot.hasChildren() {
                    guard let data = snapshot.value as? [String:Double] else {
                        return
                    }
                    print(data)
                    let coordinate = CLLocation(latitude: data["lat"] ?? 0, longitude: data["lon"] ?? 0)
                    print("Distance : \(coordinate.distance(from: CafeterriaLocation.location))")
                    //Distance in meters
                    if coordinate.distance(from: CafeterriaLocation.location) <= 100 {
                        self.delegate?.onCustomerLocationUpdated(status: 3)
                    } else {
                        self.delegate?.onCustomerLocationUpdated(status: 2)
                    }
                }
            })
    }
    
}
// MARK: - List of Protocol handlers

protocol FirebaseActions {
    
    func onConnectionLost()
    
    func isSignUpSuccessful(user: User?)
    func isExisitingUser(error: String)
    func isSignUpFailedWithError(error: Error)
    func isSignUpFailedWithError(error: String)
    
    func onUserDataUpdated(user: User?)
    func onUserUpdateFailed(error: String)
    
    func onPasswordChanged()
    func onPasswordChangeFailedWithError(error: String)
    
    func onUserNotRegistered(error: String)
    func onUserSignInSuccess(user: User?)
    func onUserSignInFailedWithError(error: Error)
    func onUserSignInFailedWithError(error: String)
    
    func onResetPasswordEmailSent()
    func onResetPasswordEmailSentFailed(error: String)
    
    func onCategoriesLoaded(categories: [FoodCategory])
    func onFoodItemsLoaded(foodItems: [FoodItem])
    func onFoodItemsLoadFailed(error: String)
    
    func onFoodItemStatusChanged(index: Int, status: Bool)
    func onFoodItemStatusNotChanged(index: Int)
    
    func onFoodCategoryAdded()
    func onFoodCategoryNotAdded()
    
    func onFoodCategoryRemoved()
    func onFoodCategoryNotRemoved()
    
    func onFoodItemAdded()
    func onFoodItemNotAdded()
    
    func onAllOrdersLoaded(orderedList: [Order])
    func onAllOrdersLoadFailed(error: String)
    
    func onOrderStatusChanged(status: Int)
    func onOrderStatusNotChanged()
    
    func onCustomerLocationUpdated(status: Int)
}

// MARK: - Protocol Extensions

extension FirebaseActions {
    func isSignUpSuccessful(user: User?){}
    func isExisitingUser(error: String){}
    func isSignUpFailedWithError(error: Error){}
    func isSignUpFailedWithError(error: String){}
    
    func onUserDataUpdated(user: User?) {}
    func onUserUpdateFailed(error: String) {}
    
    func onPasswordChanged() {}
    func onPasswordChangeFailedWithError(error: String) {}
    
    func onUserNotRegistered(error: String){}
    func onUserSignInSuccess(user: User?){}
    func onUserSignInFailedWithError(error: Error){}
    func onUserSignInFailedWithError(error: String){}
    
    func onResetPasswordEmailSent(){}
    func onResetPasswordEmailSentFailed(error: String){}
    
    func onCategoriesLoaded(categories: [FoodCategory]){}
    func onFoodItemsLoaded(foodItems: [FoodItem]){}
    func onFoodItemsLoadFailed(error: String){}
    
    func onFoodItemStatusChanged(index: Int, status: Bool){}
    func onFoodItemStatusNotChanged(index: Int){}
    
    func onFoodCategoryAdded(){}
    func onFoodCategoryNotAdded(){}
    
    func onFoodCategoryRemoved(){}
    func onFoodCategoryNotRemoved(){}
    
    func onFoodItemAdded(){}
    func onFoodItemNotAdded(){}
    
    func onAllOrdersLoaded(orderedList: [Order]){}
    func onAllOrdersLoadFailed(error: String){}
    
    func onOrderStatusChanged(status: Int){}
    func onOrderStatusNotChanged(){}
    
    func onCustomerLocationUpdated(status: Int){}
}
