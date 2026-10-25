//
//  Global.swift
//  StockVersus
//
//  Created by Charlie DiGiovanna on 5/2/17.
//  Copyright © 2017 Charlie DiGiovanna. All rights reserved.
//

import Foundation
import UIKit

var USER_ID = ""
var USER_NAME = ""
var USER_USERNAME  = ""

let NUM_PORTFOLIOS: Int32 = 100 // fake
let PORTFOLIO_START_VALUE: Float = 100000.00

#if targetEnvironment(simulator) // if running on simulator, route to localhost
let API_URL = "http://localhost:3939"
let TESTING = true
#else                            // otherwise, route to CharlieD.me server
let API_URL = "http://13.58.53.92:3939"
let TESTING = false
#endif

enum TimeUnit: Int {
    case day = 0, week, month, quarter, year, alltime
}

func rankPercentString(for ranking: Int32) -> String {
    let rp = (Float(ranking) - 0.5) / Float(NUM_PORTFOLIOS)
    let nearest5 = Int(rp * 100 / 20) + 1
    let nearest10 = Int(rp * 100 / 10) + 1

    var return_string: String
    if nearest5 == 1 && nearest10 == 1 {
        return_string = "Top \(Int(rp*100) + 1)%"
    } else if nearest10 <= 6 {
        return_string = "Top \(nearest10)0%"
    } else {
        return_string = "Bottom \(11-nearest10)0%"
    }

    return return_string
}

func dollarChangeString(for balance: Float, since balanceOld: Float, times: Float = 1) -> String {
    let pm = balance >= balanceOld ? "+" : ""

    return pm + (Float(times) * (balance - balanceOld)).dollarString
}

func percentChangeString(for balance: Float, since balanceOld: Float, withoutPlusMinus: Bool=false) -> String {
    let pm = balance >= balanceOld && !withoutPlusMinus ? "+" : ""

    return pm + (100 * (balance/balanceOld - 1)).with2DecimalPlaces + "%"
}

func priceChangeString(for balance: Float, since balanceOld: Float, times: Float = 1) -> String {
    return "\(dollarChangeString(for: balance, since: balanceOld, times: times)) (\(percentChangeString(for: balance, since: balanceOld, withoutPlusMinus: true)))"
}

func dateFromString(_ dateString: String) -> Date? {
    let formatter: DateFormatter = DateFormatter()

    // Format 1
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let date = formatter.date(from: dateString) {
        return date
    }

    // Format 2
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSSZ"
    if let date = formatter.date(from: dateString) {
        return date
    }

    print("ERROR:", "Could not parse date: \(dateString).") // Using NOW as date")
    //        return Date()

    return nil
}


func changeColor(for balance: Float, since balanceOld: Float, opposite: Bool = false) -> UIColor {
    return (balance >= balanceOld) != opposite ? .appGreen : .appRed
}

func stringFromDate(_ date: Date) -> String {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSSZZ"

    return dateFormatter.string(from: date)
}

extension Date {
    var prettyButShortDateTimeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        return formatter.string(from: self).components(separatedBy: " at ").joined(separator: " ")
    }

    var prettyDateTimeDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short

        return formatter.string(from: self).components(separatedBy: " at ").joined(separator: " ")
    }

    var prettyDateDescription: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long

        return formatter.string(from: self)
    }

    var prettyTimeDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        return formatter.string(from: self)
    }
}

extension Float {
    var dollarString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: self as NSNumber)!
    }

    var with2DecimalPlaces: String {
        let negative = self < 0
        let abs_val = abs(self)
        let index1 = abs_val.dollarString.index(after: abs_val.dollarString.startIndex)
        let without_dollar_string = String(abs_val.dollarString[index1...])
        let prefix =  negative ? "-" : ""
        return prefix + without_dollar_string
    }
}


extension UIColor {
    static var appGreen: UIColor {
        return UIColor(red:0.40, green:0.79, blue:0.30, alpha:1.00)
    }

    static var appRed: UIColor {
        return UIColor(red:1.00, green:0.30, blue:0.31, alpha:1.00)
    }
}
