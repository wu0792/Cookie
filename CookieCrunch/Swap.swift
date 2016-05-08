//
//  Swap.swift
//  CookieCrunch
//
//  Created by wu0792Mac on 16/5/5.
//  Copyright © 2016年 wu0792Mac. All rights reserved.
//

import Foundation

struct Swap: CustomStringConvertible,Hashable {
    let cookieA: Cookie
    let cookieB: Cookie
        
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
    
    var hashValue: Int{
        get{return cookieA.hashValue^cookieB.hashValue}
    }
    
}

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB) ||
        (lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
}