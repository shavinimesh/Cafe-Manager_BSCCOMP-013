//
//  RealmDB.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation
import RealmSwift

class RealmDB {
    static let instance = RealmDB()
    let realm = try! Realm()
        
    //Make Singleton
    fileprivate init() {}

    func addToCart(cartItem: CartItem, callback: (Bool) -> Void) {
        do {
            let item = realm.objects(CartItem.self).filter("itemName =%@", cartItem.itemName)
            if let item = item.first {
                NSLog("Item Exists in cart increasing quantity")
                try realm.write {
                    item.itemCount += cartItem.itemCount
                    callback(true)
                }
            } else {
                try realm.write {
                    NSLog("Item does not exists in cart adding item")
                    realm.add(cartItem)
                    callback(true)
                }
            }
        } catch {
            print(error.localizedDescription)
            callback(false)
        }
    }
    
    func getCartItems() -> [CartItem] {
        return Array(realm.objects(CartItem.self))
    }
    
    func deleteFromCart(cartItem: CartItem, callback: (Bool) -> Void) {
        do {
            if let item = realm.objects(CartItem.self).filter("itemName =%@", cartItem.itemName).first {
                NSLog("Deleting in progress")
                try realm.write {
                    realm.delete(item)
                    callback(true)
                }
            }
        } catch {
            print(error.localizedDescription)
            callback(false)
        }
    }
    
    func updateItemQTY(cartItem: CartItem, increased: Bool, callback: (Bool) -> Void) {
        do {
            let item = realm.objects(CartItem.self).filter("itemName =%@", cartItem.itemName)
            if let item = item.first {
                NSLog("Item Exists in cart increasing quantity")
                try realm.write {
                    if increased {
                        item.itemCount += 1
                    } else {
                        item.itemCount -= 1
                    }
                    callback(true)
                }
            } else {
                callback(false)
                NSLog("Could not find item to update")
            }
        } catch {
            print(error.localizedDescription)
            callback(false)
        }
    }
    
    func removeAllFromCart(callback: (Bool) -> Void) {
        do {
            try realm.write {
                realm.delete(realm.objects(CartItem.self))
                callback(true)
            }
        } catch {
            print(error.localizedDescription)
            callback(false)
        }
    }
}

