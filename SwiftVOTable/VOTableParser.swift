//
//  VOTableParser.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 04/04/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Foundation
import Runes

public class VOTableParser: NSObject, NSXMLParserDelegate {
    
    public let xmlString: String!
    public var votable: VOTable?
    private var currentElement: NSObject?
    private let VOTableClasses: [NSObject.Type]
    private let VOTableClassNames: [NSString]

    public init?(xmlString: String?) {
        self.xmlString = xmlString
        self.votable = nil
        
        self.VOTableClasses = [Resource.self, Table.self]
        self.VOTableClassNames = self.VOTableClasses.map({ (NSStringFromClass($0).componentsSeparatedByString(".").last! as String).lowercaseString })
        
        super.init()

        if xmlString == nil || xmlString!.isEmpty {
            return nil
        }
    }
    
    public func parse() -> Bool {
        self.votable = nil
        self.currentElement = nil

        let xmlParser = NSXMLParser(data: xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        xmlParser.delegate = self
        
        if xmlParser.parse() {
            return true
        }
        return false
    }
    
    public func parserDidStartDocument(parser: NSXMLParser) {
        
    }

    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        println("element start: \(elementName)")

        if (elementName.uppercaseString == "VOTABLE" && votable == nil) {
            self.votable = VOTable(attributeDict)
            currentElement = votable
        }
        else {
            if let index = find(self.VOTableClassNames, elementName.lowercaseString) {
                let voClass = VOTableClasses[index] as NSObject.Type

                let propertyName = elementName.lowercaseString
                let propertyPluralName = propertyName.plural()

                var newElement = voClass()
                if (currentElement!.hasProperty(propertyName) == true) {
                    // Current element has property of that name. Set the property, and move the 'currentElement' cursor to the new one.
                    currentElement!.setValue(newElement, forKey:propertyName)
                    currentElement = newElement
                }
                else if (currentElement!.hasProperty(propertyPluralName) == true) {
                    // Current element has a plural property of that name.
                    if var props : [NSObject] = currentElement!.valueForKey(propertyPluralName) as? [NSObject] {
                        // We already have a collection type for that property. Append the new element to it.
                        props.append(newElement)
                    }
                    else {
                        // Set the property to a list containing that element.
                        currentElement!.setValue([newElement], forKey:propertyPluralName)
                    }
                    currentElement = newElement
                }
                else {
                    // Deal with error.
                }
            }
        }
    }
    
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        println("element finish: \(elementName)")
    }
    
    public func parser(parser: NSXMLParser, foundCharacters string: String?) {
        println("current element (\(currentElement)) -->> \(string)")
    }
    
    public func parserDidEndDocument(parser: NSXMLParser) {
        
    }
}

