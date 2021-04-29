//
//  BaseViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

/**
 Utility class to perform the firebase operations such as
 - RealtimeDB Operations
 - Firebase Authentication Operations
 */

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseOP {
    
    //Class instance
    static var instance = FirebaseOP()
    
    var dbRef: DatabaseReference!
    
    //Class Delegate
    var delegate: FirebaseActions?
    
    //Make Singleton
    fileprivate init() {}
    
    // MARK: - Retrieve the realtime database reference
    
    private func getDBReference() -> DatabaseReference {
        guard dbRef != nil else {
            dbRef = Database.database().reference()
            return dbRef
        }
        return dbRef
    }
    
    // MARK: - User Based Operations
    
    fileprivate func checkExistingUser(email: String, completion: @escaping (Bool, String, DataSnapshot) -> Void) {
        let email = email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_")
        self.getDBReference().child("users").child(email).observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChildren() {
                completion(true, "User already exists.", snapshot)
            } else {
                completion(false, "User does not exists", snapshot)
            }
        })
    }
    
    fileprivate func setUpAuthenticationAccount(email: String, password: String, completion: @escaping (Bool, String) -> Void) {
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
        guard let userName = user.userName, let email = user.email, let phoneNo = user.phoneNo else {
            NSLog("Empty params found on user instance")
            completion(false, "Empty params found on user instance", user)
            return
        }
        
        let data = [
            UserKeys.userName : userName,
            UserKeys.email : email,
            UserKeys.phoneNo : phoneNo,
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
        guard let email = user.email, let password = user.password else {
            NSLog("Empty params found on user instance")
            self.delegate?.isSignUpFailedWithError(error: FieldErrorCaptions.userAlreadyExistsError)
            return
        }
        
        self.checkExistingUser(email: email, completion: {
            userExistance, result, data in
            if userExistance {
                self.delegate?.isExisitingUser(error: FieldErrorCaptions.userRegistrationFailedError)
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
    
    func fetchAllFoodItems() {
        self.getDBReference().child("food_category").observeSingleEvent(of: .value, with: {
            snapshot in
            if snapshot.hasChildren() {
                
                var categoryList: [FoodCategory] = []
                var foodItemsList: [FoodItem] = []
                
                categoryList.append(FoodCategory(categoryName: "All", isSelected: true))
                
                if let data = snapshot.value as? [String: Any] {
                    for category in data {
                        guard let singleCategory = category.value as? [String: Any] else {
                            NSLog("Could not serialize inner data : singleCategory")
                            continue
                        }
                        categoryList.append(FoodCategory(categoryName: singleCategory[FoodKeys.categoryName] as! String, isSelected: false))
                        if let foodItems = singleCategory[FoodKeys.food_items] as? [String : Any] {
                            for foodItem in foodItems {
                                guard let singleFoodItem = foodItem.value as? [String: Any] else {
                                    NSLog("Could not serialize inner data : foodItems in loop")
                                    continue
                                }
                                foodItemsList.append(FoodItem(
                                                        foodName: singleFoodItem[FoodKeys.foodName] as! String,
                                                        foodDescription: singleFoodItem[FoodKeys.foodDescription] as! String,
                                                        foodPrice: singleFoodItem[FoodKeys.foodPrice] as! Double,
                                                        discount: singleFoodItem[FoodKeys.discount] as! Int,
                                                        foodImgRes: singleFoodItem[FoodKeys.foodImgRes] as! String,
                                                        foodCategory: singleCategory[FoodKeys.categoryName] as! String))
                            }
                        } else {
                            NSLog("Could not serialize inner data : foodItems")
                            self.delegate?.onFoodItemsLoadFailed(error: FieldErrorCaptions.foodDataLoadFailed)
                        }
                    }
                    //                    let sortedFood = foodItemsList.sorted { $0.foodName < $1.foodName }
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
    
    func placeFoodOrder(order: Order, email: String) {
        
        var foodItems : [String: [String : Any]] = [:]
        for i in 0..<order.orderItems.count {
            foodItems[String(i)] = [
                FoodKeys.foodName : order.orderItems[i].foodItem.foodName,
                FoodKeys.foodPrice : order.orderItems[i].foodItem.foodPrice,
                OrderKeys.itemCount : order.orderItems[i].qty
            ]
        }
        
        let data = [
            OrderKeys.orderStatusCode : order.orderStatusCode,
            OrderKeys.orderStatusString : order.orderStatusString,
            OrderKeys.orderDate : order.orderDate.currentTimeMillis(),
            OrderKeys.itemCount : order.itemCount,
            OrderKeys.orderTotal : order.orderTotal,
            OrderKeys.orderItems : foodItems,
        ] as [String : Any]
        
        self.getDBReference().child("orders")
            .child(email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_"))
            .childByAutoId()
            .setValue(data) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    self.delegate?.onOrderPlaceFailedWithError(error: FieldErrorCaptions.orderPlacingError)
                    NSLog(error.localizedDescription)
                } else {
                    self.delegate?.onOrderPlaced()
                }
            }
    }
    
    func getAllOrders(email: String) {
        self.getDBReference().child("orders")
            .child(email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_"))
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
                            var order = Order()
                            order.orderID = "\(orderData[OrderKeys.orderDate] as! Int64)"
                            order.itemCount = orderData[OrderKeys.itemCount] as! Int
                            order.orderDate = Date().getDateFromMills(dateInMills: orderData[OrderKeys.orderDate] as! Int64)
                            order.orderStatusCode = orderData[OrderKeys.orderStatusCode] as! Int
                            order.orderStatusString = orderData[OrderKeys.orderStatusString] as! String
                            order.orderTotal = orderData[OrderKeys.orderTotal] as! Double
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
                                                                                    foodImgRes: ""),
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
                    self.delegate?.onAllOrdersLoadFailed(error: FieldErrorCaptions.noOrdersFound)
                }
            })
    }
    
    func updateUser(user: User) {
        guard let userName = user.userName, let email = user.email, let phoneNo = user.phoneNo else {
            NSLog("Empty params found on user instance")
            delegate?.onUserUpdateFailed(error: FieldErrorCaptions.updateUserFailed)
            return
        }
        
        let data = [
            UserKeys.userName : userName,
            UserKeys.phoneNo : phoneNo,
        ]
        
        self.getDBReference()
            .child("users")
            .child(email.replacingOccurrences(of: ".", with: "_").replacingOccurrences(of: "@", with: "_"))
            .updateChildValues(data) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    self.delegate?.onUserUpdateFailed(error: FieldErrorCaptions.updateUserFailed)
                    NSLog(error.localizedDescription)
                } else {
                    self.delegate?.onUserDataUpdated(user: user)
                }
            }
    }
    
    func updateUserPassword(email: String, newPassword: String, existingPassword: String) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: email, password: existingPassword)
        
        user?.reauthenticate(with: credential) { data, error  in
          if let error = error {
            NSLog(error.localizedDescription)
            self.delegate?.onPasswordChangeFailedWithError(error: FieldErrorCaptions.invalidExistingPassword)
          } else {
            Auth.auth().currentUser?.updatePassword(to: newPassword, completion: {
                error in
                if let error = error {
                    self.delegate?.onPasswordChangeFailedWithError(error: FieldErrorCaptions.updatePasswordFailed)
                    NSLog(error.localizedDescription)
                } else {
                    self.delegate?.onPasswordChanged()
                }
            })
          }
        }
    }
    
}

// MARK: - List of Protocol handlers

protocol FirebaseActions {
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
    
    func onOrderPlaced()
    func onOrderPlaceFailedWithError(error: String)
    
    func onAllOrdersLoaded(orderedList: [Order])
    func onAllOrdersLoadFailed(error: String)
    
    func onOperationsCancelled()
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
    
    func onCategoriesLoaded(categories: [FoodCategory]) {}
    func onFoodItemsLoaded(foodItems: [FoodItem]) {}
    func onFoodItemsLoadFailed(error: String) {}
    
    func onOrderPlaced() {}
    func onOrderPlaceFailedWithError(error: String) {}
    
    func onAllOrdersLoaded(orderedList: [Order]) {}
    func onAllOrdersLoadFailed(error: String) {}
    
    func onOperationsCancelled(){}
}
