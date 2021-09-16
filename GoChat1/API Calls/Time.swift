//
//  Time.swift
//  GoChat
//
//  Created by Long Nguyen on 8/21/21.
//

import UIKit
import Firebase

struct Time {
    
    static func configureTime(completionBlock: @escaping([String]) -> Void) {
        
        //construct a timestamp, convert to String and upload to database
        let time = Timestamp(date: Date()) //current date
        let dateValue = time.dateValue()
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd HH:mm:ss" //just search GG to find an appropriate date format
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "MMM dd, yyyy"
        
        let timeMark = dateFormatter1.string(from: dateValue)
        let timeMarkShort = dateFormatter2.string(from: dateValue)
        let timeKey = "\(timeMark)"
        let timeShort = "\(timeMarkShort)"
        print("DEBUG-Time: done configuring time..")
        completionBlock([timeKey, timeShort])
    }
    
}
