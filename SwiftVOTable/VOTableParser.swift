//
//  VOTableParser.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 04/04/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Foundation

public class VOTableParser: NSObject, NSXMLParserDelegate {
    
    let xmlString: String!
    var votable: VOTable?
    private var currentElement: NSObject?
    private let VOTableClasses: [NSObject.Type]
    private let VOTableClassNames: [NSString]

    init?(xmlString: String?) {
        self.xmlString = xmlString
        self.votable = nil
        
        self.VOTableClasses = [Resource.self, Table.self]
        self.VOTableClassNames = self.VOTableClasses.map({ (NSStringFromClass($0) as String).lowercaseString })
        
        super.init()

        if xmlString == nil || xmlString!.isEmpty {
            return nil
        }
    }
    
    public func parse() -> Bool {
        votable = nil
        currentElement = nil

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
        if (elementName.uppercaseString == "VOTABLE" && votable == nil) {
            votable = VOTable(rawAttributes: attributeDict)
            currentElement = votable
        }
        else {
            if let index = find(self.VOTableClassNames, elementName.lowercaseString) {
                let propName = elementName.lowercaseString
                let propPluralName = propName.plural()

                let voClass = VOTableClasses[index] as NSObject.Type
                if let hasProperty = currentElement?.hasProperty(propName) {
                    currentElement?.setValue(voClass(), forKey:propName)
                }
                else if let hasProperty = currentElement?.hasProperty(propPluralName) {
                    currentElement = voClass()
                    if var props : [NSObject] = currentElement?.valueForKey(propPluralName) as? [NSObject] {
                        props.append(currentElement!)
                    }
                    else {
                        currentElement?.setValue([voClass()], forKey:className.lowercaseString)
                    }
                }
                // At this stafe, currentElement is not pointing to the right object...
            }
        }
    }
    
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        println("element finish: \(elementName)")
    }
    
    public func parser(parser: NSXMLParser, foundCharacters string: String?) {
    }
    
    public func parserDidEndDocument(parser: NSXMLParser) {
        
    }
}

