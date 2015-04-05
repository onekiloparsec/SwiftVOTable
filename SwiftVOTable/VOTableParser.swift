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
}

public class VOTableParser: NSObject, NSXMLParserDelegate {
    
    let xmlString: String!
    var votable: VOTable?

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
            votable = VOTable(resources: nil)
            
            if (!attributeDict.isEmpty) {
                for (keyAny, valueAny) in attributeDict {
                    let keyString = keyAny as! String
                    let valueString = valueAny as! String
                    if (keyString.uppercaseString == VOTableConstantKeys.versionKey) {
                        votable?.version = valueString
                    }
                    else {
                        if (votable?.attributes == nil) {
                            votable?.attributes = [:]
                        }
                        votable?.attributes?[keyString] = valueString
                    }
                }
            }
        }
        println("element start: \(elementName) \(namespaceURI) \(qName) \(attributeDict)")
    }
    
    public func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        println("element finish: \(elementName)")
    }
    
    public func parser(parser: NSXMLParser, foundCharacters string: String?) {
    }
    
    public func parserDidEndDocument(parser: NSXMLParser) {
        
    }
}

