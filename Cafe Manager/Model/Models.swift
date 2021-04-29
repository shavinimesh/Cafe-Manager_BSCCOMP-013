//
//  Models.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation
import RealmSwift

struct FoodCategory {
    var categoryName: String
    var isSelected: Bool
}

struct FoodItem {
    var foodName: String
    var foodDescription: String
    var foodPrice: Double
    var discount: Int
    var foodImgRes: String
    var foodCategory: String = ""
    var discountedPrice: Double {
        return foodPrice - (foodPrice * (Double(discount)/100))
    }
}

class CartItem: Object {
    @objc dynamic var itemName: String = ""
    @objc dynamic var itemImgRes: String = ""
    @objc dynamic var discount: Int = 0
    @objc dynamic var itemPrice: Double = 0
    @objc dynamic var itemCount: Int = 0
    var itemTotal: Double {
        return Double(itemCount) *  discountedPrice
    }
    var discountedPrice: Double {
        return itemPrice - (itemPrice * (Double(discount)/100))
    }
}

struct User: Codable {
    var _id: String?
    var userName: String?
    var email: String?
    var phoneNo: String?
    var password: String?
    var imageRes: String?
    
    init(_id: String?, userName: String?, email: String?, phoneNo: String?, password: String?, imageRes: String?) {
        self._id = _id
        self.userName = userName
        self.email = email
        self.phoneNo = phoneNo
        self.password = password
        self.imageRes = imageRes
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decodeIfPresent(String.self, forKey: ._id)
        self.userName = try container.decodeIfPresent(String.self, forKey: .userName)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.phoneNo = try container.decodeIfPresent(String.self, forKey: .phoneNo)
        self.password = try container.decodeIfPresent(String.self, forKey: .password)
        self.imageRes = try container.decodeIfPresent(String.self, forKey: .imageRes)
    }
}

struct Order {
    var orderID: String = ""
    var orderStatus: OrderStatus {
        if orderStatusCode == 0 {
            return .ORDER_PENDING
        }
        if orderStatusCode == 1 {
            return .ORDER_READY
        }
        return .ORDER_COMPLETED
    }
    //0 = Pending Order | 1 = Order ready | 2 = completed
    var orderStatusCode: Int = 0
    var orderStatusString: String = ""
    var orderDate: Date = Date()
    var itemCount: Int = 0
    var orderTotal: Double = 0
    var orderItems: [OrderItem] = []
}

struct OrderItem {
    var foodItem: FoodItem
    var qty: Int
}

enum OrderStatus {
    case ORDER_PENDING
    case ORDER_READY
    case ORDER_COMPLETED
}
