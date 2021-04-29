//
//  DateExtension.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation

extension Date {
    //get date in milliseconds
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    /**
        Converts the date in milliseconds to actual date format [MM-dd-yyyy]
     
        - parameter message : date in milliseconds
     
     */
    func getDateFromMills(dateInMills: Int64) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: Date(timeIntervalSince1970: (Double(dateInMills) / 1000.0)))
    }
    
    func getDateFromMills(dateInMills: Int64) -> Date {
        return Date(timeIntervalSince1970: (Double(dateInMills) / 1000.0))
    }
    
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: Date())
    }
}
