//
//  VOTableUtils.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 08/06/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Foundation

extension NSObject {
    
    // Borrowed from https://www.weheartswift.com/swift-objc-magic/
    func propertyNames() -> [String] {
        var names: [String] = []
        var count: UInt32 = 0
        // Uses the Objc Runtime to get the property list
        var properties = class_copyPropertyList(self.dynamicType, &count)
        for var i = 0; i < Int(count); ++i {
            let property: objc_property_t = properties[i]
            let name: String = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding) as! String
            names.append(name)
        }
        free(properties)
        return names
    }
    
    func hasProperty(name: String) -> Bool! {
        return Set(self.propertyNames()).contains(name)
    }
}

extension String {
    
    var length: Int {
        return Int(count(self))
    }

    func plural() -> String {
        let index: String.Index = advance(self.startIndex, self.length-1)
        if self.length == 0 || self.substringFromIndex(index) == "s" {
            return self;
        }
        return self + "s"
    }
}

// See http://www.juliusparishy.com/articles/2014/12/14/adopting-map-reduce-in-swift
func join<T : Equatable>(objs: [T], separator: String) -> String {
    return objs.reduce("") {
        sum, obj in
        let maybeSeparator = (obj == objs.last) ? "" : separator
        return "\(sum)\(obj)\(maybeSeparator)"
    }
}

