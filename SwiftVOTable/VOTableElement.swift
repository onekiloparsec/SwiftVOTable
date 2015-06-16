//
//  VOTableElement.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 12/06/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Foundation

struct VOTableTranslations {
    static let PropertyAliases = [
        "id": "ID",
        "description": "voDescription",
        "tabledata": "tableData",
        "tr": "row",
        "td": "cell"
    ]
}

public class VOTableElement: NSObject {
    public var customAttributes: Dictionary<String, String> = [:]
    public weak var parentElement: VOTableElement?
    
    required public init(_ rawAttributes: [NSObject : AnyObject]?) {
        super.init()
        
        if let rawAttr = rawAttributes {
            /// We have an attributes dictionary. Store in properties when possible, otherwise in customAttributes.
            let propNamesSet = Set(self.propertyNames())
            
            for (keyAny, valueAny) in rawAttr {
                let keyString = keyAny as! String
                if propNamesSet.contains(keyString) {
                    self.setValue(valueAny, forKey:keyString)
                }
                else {
                    self.customAttributes[keyString] = valueAny as? String
                }
            }
        }
    }
        
    public func setNewElement(newElement: VOTableElement, var forPropertyName propertyName: String) {
        let translationKeys = VOTableTranslations.PropertyAliases.keys.array
        if (find(translationKeys, propertyName) != nil) {
            propertyName = VOTableTranslations.PropertyAliases[propertyName]!
        }
        
        let propertyPluralName = propertyName.plural()
        
        if (self.hasProperty(propertyName) == true) {
            // Current element has property of that name. Set the property, and move the 'currentElement' cursor to the new one.
            self.setValue(newElement, forKey:propertyName)
//            println("Setting \(newElement) for property '\(propertyName)' to \(self)")
        }
        else if (self.hasProperty(propertyPluralName) == true) {
            // Current element has a plural property of that name.
            if var props : [NSObject] = self.valueForKey(propertyPluralName) as? [NSObject] {
                // We already have a collection type for that property. Append the new element to it.
                props.append(newElement)
                // Not sure why, but we need to re-set the value.
                self.setValue(props, forKey: propertyPluralName)
//                println("Appending \(newElement) for property '\(propertyPluralName)' to \(self)")
            }
            else {
                // Set the property to a list containing that element.
                self.setValue([newElement], forKey:propertyPluralName)
//                println("Setting [\(newElement)] for property '\(propertyPluralName)' to \(self)")
            }
        }
        else {
            println("Can't set [\(newElement)] for property '\(propertyName)' to \(self)")
        }
        
        newElement.parentElement = self;
    }
    
    public func voTableString() -> String {
        let className = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!.uppercaseString
        
        var xmlOpening = String()
        var xmlChildren = String()
        let propertyNames = self.filteredPropertyNames()
        
        // Element opening
        xmlOpening += "<\(className)"
        
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
        
        // One must certainly be able to reduce this a lot.
        let childrenArrayNames = propertyNames.filter({$0 != "customAttributes"}).filter({ self.isPropertyAnArray($0) })
        for childArrayName in childrenArrayNames {
            if let childArray: Array<VOTableElement> = self.valueForKey(childArrayName) as? Array<VOTableElement> {
                for childElement: VOTableElement in childArray {
                    xmlChildren += childElement.voTableString()
                }
            }
        }
        
        if (self.hasProperty("content")! && self.valueForKey("content")?.length > 0) {
            xmlChildren += self.valueForKey("content") as! String!
        }
        
        if xmlChildren.length > 0 {
            xmlOpening += ">\n"
            let xmlClosing = "</\(className)>\n"
            return xmlOpening + xmlChildren + xmlClosing
        }
        else {
            xmlOpening += " />\n"
            return xmlOpening
        }
    }
}
