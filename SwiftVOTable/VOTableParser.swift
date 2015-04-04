//
//  VOTableParser.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 04/04/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Foundation

struct VOTableConstants{
    static let votable = "VOTABLE"
}

class VOTableParser: NSObject, NSXMLParserDelegate {
    
    let xmlString: String!
    var votable: VOTable?

    init?(xmlString: String?) {
        super.init()

        if xmlString == nil || xmlString!.isEmpty {
            return nil
        }

        self.xmlString = xmlString
    }
    
    func parse() -> Bool {
        votable = nil
        
        let xmlParser = NSXMLParser(data: xmlString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
        xmlParser.delegate = self
        
        if xmlParser.parse() {
            return true
        }
        return false
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        println("element start: \(elementName)")
    }
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
        println("element finish: \(elementName)")
    }
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!) {
    }
}

