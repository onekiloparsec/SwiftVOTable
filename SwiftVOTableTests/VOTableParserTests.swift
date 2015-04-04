//
//  VOTableParserTests.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 04/04/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import Cocoa
import XCTest
import SwiftVOTable

class VOTableParserTests: XCTestCase {
    
    var simpleTableXMLString: String!
    
    override func setUp() {
        super.setUp()
        
        println(NSBundle.mainBundle().resourcePath)
        let path = NSBundle(forClass: self.dynamicType).pathForResource("OfficialVOTableDocSimpleTable", ofType: "txt")
        simpleTableXMLString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
}

