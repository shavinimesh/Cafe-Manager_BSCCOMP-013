//
//  Constraints.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import CoreLocation

struct StoryBoardSegues {
    static let signInToHome = "signInToHome"
    static let signUpHome = "signUpHome"
    static let ordersToOrderInfo = "ordersToOrderInfo"
    static let AccountToPreview = "AccountToPreview"
}

//Name of the SessionVariables
struct UserSession {
    static let USER_SESSION = "USER_SESSION"
    static let IS_LOGGED_IN = "AUTH_STATE"
}

//List of error captions and messages
struct FieldErrorCaptions {
    static let noConnectionTitle = "No internet connection"
    static let noConnectionMessage = "The app requires a working internet connection please check your connection settings."
    static let generalizedError = "Unknown error occured, please retry!"
    
    // MARK: - User based Error captions
    static let userRegistrationFailedError = "User registration failed, please retry!"
    static let userAlreadyExistsError = "The user already exists!"
    static let userNotRegisteredError = "The user does not exists!"
    static let userSignInFailedError = "User sign in failed, please retry!"
    static let userSignInWithInvalidCredentials = "Invalid user credentials!"
    static let userResetPasswordFailed = "Failed to reset password!"
    
    static let noFoodItems = "No food Items found."
    static let foodDataLoadFailed = "Could not load foods!"
    
    static let updateUserFailed = "Failed to update user!"
    
    static let updatePasswordFailed = "Faild to update password!"
    static let invalidExistingPassword = "Invalid existing password!"
    
    static let noOrdersFound = "No orders found!"
    static let orderLoadFailed = "Failed to load orders!"
}

struct InputErrorCaptions {
    static let invalidEmailAddress = "Invalid Email address"
    static let invalidPassword = "Invalid Password"
    static let invalidName = "Invalid Name"
    static let invalidPhoneNo = "Invalid phone no."
    static let passwordNotMatched = "Passwords does not match"
    static let invaliCategorydName = "Invalid category"
    static let invalidFoodName = "Invalid food name"
    static let invalidFoodPrice = "Invalid food price"
    static let invalidFoodDescription = "Invalid food description"
    static let invalidDiscount = "Invalid discount"
}

struct AppConfig {
    static let connectionCheckTimeout: Double = 10
    static let passwordMinLength = 6
    static let passwordMaxLength = 20
    static let defaultPasswordPlaceholder = "****"
}

class UserKeys {
    class var userName : String { return "userName" }
    class var email : String { return "email" }
    class var phoneNo : String { return "phoneNo" }
    class var password : String { return "password" }
    class var type : String { return "type" }
}

class FoodKeys {
    class var categoryName: String { return "categoryName" }
    class var food_items: String { return "food_items" }
    class var discount: String { return "discount" }
    class var foodDescription: String { return "foodDescription" }
    class var foodImgRes: String { return "foodImgRes" }
    class var foodName: String { return "foodName" }
    class var foodPrice: String { return "foodPrice" }
    class var isActive: String { return "isActive" }
}

class OrderKeys {
    class var orderID: String { return "orderID" }
    class var orderStatusCode: String { return "orderStatusCode" }
    class var orderStatusString: String { return "orderStatusString" }
    class var orderDate: String { return "orderDate" }
    class var itemCount: String { return "itemCount" }
    class var orderTotal: String { return "orderTotal" }
    class var orderItems: String { return "orderItems" }
    class var customerName: String { return "customerName" }
    class var customerEmailEscapedString: String { return "customerEmail" }
}

class CafeterriaLocation {
    class var location: CLLocation {
        return CLLocation(latitude: 6.90636, longitude: 79.87066)
    }
}
