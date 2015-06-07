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
    private var currentElement: VOTableElement?
    private let VOTableClasses: [VOTableElement.Type]
    private let VOTableClassNames: [NSString]

    public init?(xmlString: String?) {
        self.xmlString = xmlString
        self.votable = nil
        
        self.VOTableClasses = [VOTable.self, Resource.self, Table.self]
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

        if let index = find(self.VOTableClassNames, elementName.lowercaseString) {
            let voClass = VOTableClasses[index] as VOTableElement.Type

            var newElement = voClass(attributeDict)
            
            if (index == 0) {
                self.votable = newElement as? VOTable;
            }
            
            if (currentElement != nil) {
                currentElement?.setNewElement(newElement, forPropertyName:elementName.lowercaseString);
            }

            currentElement = newElement
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

