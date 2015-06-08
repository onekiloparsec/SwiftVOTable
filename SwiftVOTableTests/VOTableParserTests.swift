//
//  VOTableParserTests.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 04/04/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import UIKit
import XCTest
import Runes
import SwiftVOTable

class VOTableParserTests: XCTestCase {
    
    var simpleTableXMLString: String!
    
    override func setUp() {
        super.setUp()
        
        println(NSBundle.mainBundle().resourcePath)
        let path = NSBundle(forClass: self.dynamicType).pathForResource("OfficialVOTableDocSimpleTable", ofType: "txt")
        simpleTableXMLString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testInitParserWithNilString() {
        let parser = VOTableParser(xmlString: nil)
        XCTAssertNil(parser, "Parser should not be initialised.")
    }

    func testInitParserWithEmptyString() {
        let parser = VOTableParser(xmlString: "")
        XCTAssertNil(parser, "Parser should not be initialised.")
    }

    func testInitParserWithValidString() {
        let parser = VOTableParser(xmlString: simpleTableXMLString)
        XCTAssertNotNil(parser, "Parser should be initialised.")
    }
    
    func testParserVOTableElement() {
        let parser = VOTableParser(xmlString: simpleTableXMLString)
        parser?.parse()
        XCTAssertNotNil(parser?.votable, "One must have a VOTable instance.");
        XCTAssertNotNil(parser?.votable?.customAttributes, "One must have an attribute instance attached to the table.");
        XCTAssertTrue(parser?.votable?.version == "1.3", "Version of VOTable is wrong.")
    }

    func testParserVOTableResource() {
        let parser = VOTableParser(xmlString: simpleTableXMLString)
        parser?.parse()
        XCTAssertTrue(parser?.votable?.resources?.count == 1, "Resources cannot be found.")
        let resource : Resource? = parser?.votable?.resources?.first;
        XCTAssertTrue(resource?.name == "myFavouriteGalaxies", "Resource name could not be found.");
        
        println("\(parser!.votable!.voTableString())")
    }
}

