//
//  DateUtil.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation

class DateUtil {
    static let dateFormatter = DateFormatter()
    
    static func getDate(date: Date, formatter: String = "MMM d, yyyy") -> String {
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: date)
    }
    
    static func getDate(date: String, formatter: String = "MM-dd-yyyy HH:mm") -> Date {
        dateFormatter.dateFormat = formatter
        return dateFormatter.date(from: date)!
    }
    
    static func getDays(fromDate: Date, toDate: Date = Date()) -> Int {
        return Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day ?? 0
    }
}

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
