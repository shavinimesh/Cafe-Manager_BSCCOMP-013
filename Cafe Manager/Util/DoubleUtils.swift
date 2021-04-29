//
//  DoubleUtils.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation


extension Double {
    var lkrString: String {
        return String(format: "RS. %.2f", self)
    }
    
    var amountString: String {
        return String(format: "%.2f", self)
    }
    
    static func getLKRString(amount: Double) -> String {
        return String(format: "RS. %.2f", amount)
    }
    
}
