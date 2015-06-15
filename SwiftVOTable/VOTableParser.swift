//
//  VOTableParser.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 04/04/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Foundation

public class VOTableParser: NSObject, NSXMLParserDelegate {
    
    public let xmlString: String!
    public var votable: VOTable?
    
    private var currentElement: VOTableElement?
    private var currentContent: String?
    
    private let elementClasses: [VOTableElement.Type]
    private let elementNames: [NSString]

    public init?(xmlString: String?) {
        self.xmlString = xmlString
        self.votable = nil
        
        self.elementClasses = [VOTable.self, Resource.self, Table.self, Group.self, Param.self, Field.self,
            Description.self, FIELDRef.self, PARAMRef.self, Data.self, TableData.self, TR.self, TD.self]
        
        self.elementNames = self.elementClasses.map({ (NSStringFromClass($0).componentsSeparatedByString(".").last! as String).lowercaseString })
        
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

        if let index = find(self.elementNames, elementName.lowercaseString) {
            
            let voClass = elementClasses[index] as VOTableElement.Type
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
    
    public func parser(parser: NSXMLParser, foundCharacters string: String?) {
        if let contentString = string {
            if currentContent == nil {
                currentContent = ""
            }
            currentContent! += contentString
        }
    }

    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // One must check for the validity of elementName. If it is now known / valid, one shouldn't set a new value
        // to currentElement to avoid moving up in the hierarchy while we haven't been down in the didStartElement.
        if let index = find(self.elementNames, elementName.lowercaseString) {
            
            if currentElement?.hasProperty("content") == true && currentContent?.length > 0 {
                currentElement?.setValue(currentContent, forKey: "content")
            }
            
            currentElement = currentElement?.parentElement
            currentContent = ""
        }
    }
    
    public func parserDidEndDocument(parser: NSXMLParser) {
        
    }
}

