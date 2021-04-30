//
//  Models.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation
import RealmSwift

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

struct FoodCategory {
    var categoryID: String
    var categoryName: String
    var isSelected: Bool
}

struct FoodItem {
    var foodItemID: String = ""
    var foodName: String
    var foodDescription: String
    var foodPrice: Double
    var discount: Int
    var foodImgRes: String
    var foodCategory: String = ""
    var isActive: Bool
    var discountedPrice: Double {
        return foodPrice - (foodPrice * (Double(discount)/100))
    }
}

struct Order {
    var orderID: String = ""
    var orderStatus: OrderStatus {
        switch orderStatusCode {
        case 0:
            return .ORDER_PENDING
        case 1:
            return .ORDER_PREPERATION
        case 2:
            return .ORDER_READY
        case 3:
            return .ORDER_ARRIVING
        case 4:
            return .ORDER_COMPLETED
        case 5:
            return .ORDER_CANCELLED
        default:
            return .ORDER_CANCELLED
        }
    }

    var orderStatusCode: Int = 0
    var orderStatusString: String = ""
    var orderDate: Date = Date()
    var itemCount: Int = 0
    var orderTotal: Double = 0
    var orderItems: [OrderItem] = []
    var customername: String = ""
}

struct OrderItem {
    var foodItem: FoodItem
    var qty: Int
}

enum OrderStatus: String {
    case ORDER_PENDING = "Pending"//0
    case ORDER_PREPERATION = "Prep."//1
    case ORDER_READY = "Ready"//2
    case ORDER_ARRIVING = "Arrived"//3
    case ORDER_COMPLETED = "Done"//4
    case ORDER_CANCELLED = "Cancel"//5
}

struct OrderStatusInt {
    static let ORDER_PENDING = 0
    static let ORDER_PREPERATION = 1
    static let ORDER_READY = 2
    static let ORDER_ARRIVING = 3
    static let ORDER_COMPLETED = 4
    static let ORDER_CANCELLED = 5
}
