//
//  VOTableParser.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 04/04/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Foundation

struct VOTableConstantKeys {
    static let votableKey = "VOTABLE"
    static let versionKey = "VERSION"
    static let resourceKey = "RESOURCE"
}

public class VOTableParser: NSObject, NSXMLParserDelegate {
    
    let xmlString: String!
    var votable: VOTable?
    private var currentElement: Any?

    init?(xmlString: String?) {
        self.xmlString = xmlString
        self.votable = nil
        super.init()

        if xmlString == nil || xmlString!.isEmpty {
            return nil
        }
    }
    
    public func parse() -> Bool {
        votable = nil
        
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
        if (elementName.uppercaseString == VOTableConstantKeys.votableKey && votable == nil) {
            votable = VOTable(rawAttributes: attributeDict)
            currentElement = votable
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

