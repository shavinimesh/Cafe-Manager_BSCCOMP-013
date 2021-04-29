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
