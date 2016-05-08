//
//  Extensions.swift
//  CookieCrunch
//
//  Created by wu0792Mac on 16/5/4.
//  Copyright © 2016年 wu0792Mac. All rights reserved.
//

import Foundation

extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource("Levels/" + filename, ofType: "json") {
            do{
                let data = NSData(contentsOfFile: path)
                //let data = NSData(contentsOfFile: path, options: NSDataReadingOptions(), error: &error)
                if let data = data {
                    
                    let dictionary: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
                    if let dictionary = dictionary as? Dictionary<String, AnyObject> {
                        return dictionary
                    } else {
                        print("Level file '\(filename)' is not valid JSON")
                        return nil
                    }
                } else {
                    print("Could not load level file: \(filename)")
                    return nil
                }
            }catch{
                print("error happed:\(error)")
                return nil
            }
            
        } else {
            print("Could not find level file: \(filename)")
            return nil
        }
    }
}