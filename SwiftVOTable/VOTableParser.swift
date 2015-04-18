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
        self.VOTableClassNames = self.VOTableClasses.map({ (NSStringFromClass($0).componentsSeparatedByString(".").last! as String).lowercaseString })
        
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
                let voClass = VOTableClasses[index] as NSObject.Type

                let propName = elementName.lowercaseString
                let propPluralName = propName.plural()

                println("element start: \(propName)")

                var newElement = voClass()
                if (currentElement!.hasProperty(propName) == true) {
                    currentElement!.setValue(newElement, forKey:propName)
                    currentElement = newElement
                }
                else if (currentElement!.hasProperty(propPluralName) == true) {
                    if var props : [NSObject] = currentElement!.valueForKey(propPluralName) as? [NSObject] {
                        props.append(newElement)
                    }
                    else {
                        currentElement!.setValue([newElement], forKey:propPluralName)
                    }
                    currentElement = newElement
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

