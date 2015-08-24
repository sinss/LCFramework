//
//  NSString+extension.swift
//  extensionSample
//
//  Created by Leo Chang on 7/8/14.
//  Copyright (c) 2014 Perfectidea. All rights reserved.
//

import Foundation

extension NSString {
    
    class func getDisplayApplicationName() -> NSString {
        var info : NSDictionary = NSBundle.mainBundle().infoDictionary!
        return info["CFBundleDisplayName"] as! NSString
    }
    
    /**
    
    */
    func toDate() -> NSDate {
        var formatter : NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.dateFromString(self as String)!
    }
    
    /**
    
    */
    func toEndOfDate() -> NSDate {
        var formatter : NSDateFormatter = NSDateFormatter();
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let dateString = NSString(format: "%@ 23:59:59", self)
        return formatter.dateFromString(dateString as String)!
    }
    
    /**
    return a date object from a full date string
    */
    func toFullDate() -> NSDate {
        var formatter : NSDateFormatter = NSDateFormatter();
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.dateFromString(self as String)!
    }
    
    /**
    Check this string is pure integer or not
    */
    func isPureInt() -> Bool {
        let scan : NSScanner = NSScanner(string: self as String)
        var val : Int = 0
        return scan.scanInteger(&val) && scan.atEnd
    }
    
    /**
    Check this string is pure float or not
    */
    func isPureDouble() -> Bool {
        let scan : NSScanner = NSScanner(string: self as String)
        var val : Float = 0.0
        return scan.scanFloat(&val) && scan.atEnd
    }
    
    func isBlank() -> Bool {
        return self.isEqualToString("") ? true : false
    }
    
    /**
    
    */
    func numberOfWords() -> NSInteger {
        var scanner : NSScanner = NSScanner(string: self as String)
        var space = NSCharacterSet .whitespaceAndNewlineCharacterSet()
        
        var count : NSInteger = 0
        
        while scanner.scanUpToCharactersFromSet(space, intoString: nil) { count += 1}
        
        return count
    }
    
    /**
    
    */
    func containString(string : NSString) -> Bool {
        return self.rangeOfString(string as String).location == NSNotFound ? false : true
    }
    
    /**
    
    */
    func addString(string : NSString) -> NSString {
        if string.isBlank() {
            return self
        }
        return string.stringByAppendingString(string as String)
    }
    
    /**
    
    */
    func removeSubString(string : NSString) -> NSString {
        if self.containsString(string as String) {
            var range : NSRange = self.rangeOfString(string as String)
            return self.stringByReplacingCharactersInRange(range, withString: string as String)
        }
        return self
    }
    
    /**
    Check email
    */
    func isValidEmail() -> Bool {
        var regex : NSString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluateWithObject(self)
    }
    
    /**
    phone number
    */
    func isValidPhoneNumber() -> Bool {
        var regex : NSString = "[235689][0-9]{6}([0-9]{3})?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluateWithObject(self)
    }
    
    /**
    url
    */
    func isValidUrl() -> Bool {
        var regex : NSString = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        
        return predicate.evaluateWithObject(self)
    }
}