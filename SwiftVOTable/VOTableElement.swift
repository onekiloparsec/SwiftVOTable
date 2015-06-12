//
//  VOTableElement.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 12/06/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Foundation

public class VOTableElement: NSObject {
    public var customAttributes: Dictionary<String, String> = [:]
    
    required public init(_ rawAttributes: [NSObject : AnyObject]?) {
        super.init()
        
        if let rawAttr = rawAttributes {
            /// We have an attributes dictionary. Store in properties when possible, otherwise in customAttributes.
            let propNamesSet = Set(self.propertyNames())
            
            for (keyAny, valueAny) in rawAttr {
                let keyString = keyAny as! String
                let valueString = valueAny as! String
                
                if propNamesSet.contains(keyString) {
                    self.setValue(valueString, forKey:keyString)
                }
                else {
                    self.customAttributes[keyString] = valueString
                }
            }
        }
    }
    
    public func setNewElement(newElement: VOTableElement, forPropertyName propertyName: String) {
        let propertyPluralName = propertyName.plural()
        
        if (self.hasProperty(propertyName) == true) {
            // Current element has property of that name. Set the property, and move the 'currentElement' cursor to the new one.
            self.setValue(newElement, forKey:propertyName)
        }
        else if (self.hasProperty(propertyPluralName) == true) {
            // Current element has a plural property of that name.
            if var props : [NSObject] = self.valueForKey(propertyPluralName) as? [NSObject] {
                // We already have a collection type for that property. Append the new element to it.
                props.append(newElement)
            }
            else {
                // Set the property to a list containing that element.
                self.setValue([newElement], forKey:propertyPluralName)
            }
        }
        else {
            // Deal with error.
        }
    }
    
    public func voTableString() -> String {
        let className = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!.uppercaseString
        
        var xmlOpening = String()
        var xmlChildren = String()
        let xmlClosing = "</\(className)>\n"
        let propertyNames = self.propertyNames()
        
        // Element opening
        xmlOpening += "<\(className) " // Note the ending white space.
        
        let attributeNames: Array<String> = propertyNames.filter({$0 != "customAttributes"}).filter({ self.valueForKey($0) is String })
        xmlOpening = attributeNames.reduce(xmlOpening) {
            wholeString, attributeName in
            return "\(wholeString) \(attributeName)=\"\(self.valueForKey(attributeName) as! String)\"" // Note the separating white space
        }
        
        if (self.customAttributes.count > 0) {
            xmlOpening = reduce(self.customAttributes, xmlOpening) {
                wholeString, keyValue in
                return "\(wholeString) \(keyValue.0)=\"\(keyValue.1)\"" // Note the separating white space
            }
        }
        
        xmlOpening += ">\n"
        
        // One must certainly be able to reduce this a lot.
        let childrenArrayNames = propertyNames.filter({$0 != "customAttributes"}).filter({ self.isPropertyAnArray($0) })
        for childArrayName in childrenArrayNames {
            if let childArray: Array<AnyObject> = self.valueForKey(childArrayName) as? Array<AnyObject> {
                if childArray is [VOTableElement] {
                    for childElement: VOTableElement in childArray as! Array<VOTableElement> {
                        xmlChildren += childElement.voTableString()
                    }
                }
            }
        }
        
        return xmlOpening + xmlChildren + xmlClosing
    }
}
