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
    private var lastTableFields: [Field]?
    private var currentCellIndex: Int
    
    private let elementClasses: [VOTableElement.Type]
    private let elementNames: [NSString]

    public init?(xmlString: String?) {
        self.xmlString = xmlString
        self.votable = nil
        self.currentCellIndex = 0

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
        self.lastTableFields = nil
        self.currentCellIndex = 0

        let xmlParser = NSXMLParser(data: xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
        xmlParser.delegate = self
        
        return xmlParser.parse();
    }
    
    public func parserDidStartDocument(parser: NSXMLParser) {}

    public func parserDidEndDocument(parser: NSXMLParser) {
        self.currentCellIndex = 0
        self.currentContent = nil
        self.currentElement = nil
    }

    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {

        if let index = find(self.elementNames, elementName.lowercaseString) {
            
            let voClass = elementClasses[index] as VOTableElement.Type
            var newElement = voClass(attributeDict)
            
            if elementName.lowercaseString == "votable" {
                self.votable = newElement as? VOTable;
            }
            
            if (currentElement != nil) {
                currentElement?.setNewElement(newElement, forPropertyName:elementName.lowercaseString);
            }

            currentElement = newElement
            
            if elementName.lowercaseString == "data" {
                self.lastTableFields = ((currentElement as! Data).parentElement as! Table).fields
            }
            else if elementName.lowercaseString == "tr" {
                self.currentCellIndex = 0
            }
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
        // One must also check here for the validity of elementName. If it is not known / valid, one shouldn't set a new value
        // to currentElement to avoid moving up in the hierarchy while we haven't been traveling down in the didStartElement.
        if let index = find(self.elementNames, elementName.lowercaseString) {
            
            if currentElement?.hasProperty("content") == true && currentContent?.length > 0 {
                currentElement?.setValue(currentContent, forKey: "content")
            }
            
            if elementName.lowercaseString == "td" {
                if let fields = self.lastTableFields {
                    assert(self.currentCellIndex < fields.count)
                    (currentElement as! TD).field = fields[self.currentCellIndex]
                }
                self.currentCellIndex += 1
            }
            else if elementName.lowercaseString == "tr" {
                self.currentCellIndex = 0
            }
            
            currentElement = currentElement?.parentElement
            currentContent = ""
        }
    }
}

