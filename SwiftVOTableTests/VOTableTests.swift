//
//  SwiftVOTableTests.swift
//  SwiftVOTableTests
//
//  Created by Cédric Foellmi on 21/03/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import UIKit
import XCTest
import SwiftVOTable

class VOTableTests: XCTestCase {
    
    var simpleTableXMLString: String!
    var simpleTableParser: VOTableParser!

    override func setUp() {
        super.setUp()

        println(NSBundle.mainBundle().resourcePath)
        let path = NSBundle(forClass: self.dynamicType).pathForResource("OfficialVOTableDocSimpleTable", ofType: "txt")
        simpleTableXMLString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        simpleTableParser = VOTableParser(xmlString: simpleTableXMLString)
        simpleTableParser.parse()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testParserVOTableResource() {
        XCTAssertTrue(simpleTableParser.votable?.resources?.count == 1, "Resources cannot be found.")
        let resource : Resource? = simpleTableParser.votable?.resources?.first;
        XCTAssertTrue(resource?.name == "myFavouriteGalaxies", "Resource name could not be found.")
    }

    func testParserVOTableResourceContent() {
        let resource : Resource? = simpleTableParser.votable?.resources?.first
        XCTAssertNil(resource?.infos, "No groups expected in resources")
        XCTAssertNil(resource?.params, "No params expected in resources")
        XCTAssertNil(resource?.groups, "No groups expected in resources")
        XCTAssertNil(resource?.links, "No links expected in resources")
        XCTAssertNotNil(resource?.tables, "Tables expected in resources")
    }

    func testParserVOTableResourceTableContent() {
        let resource : Resource? = simpleTableParser.votable?.resources?.first;
        XCTAssertTrue(resource?.tables?.first!.groups?.count == 1, "Missing groups in resources");
        XCTAssertTrue(resource?.tables?.first!.params?.count == 1, "Missing params in resources");
    }

    func testParserVOTableResourceTableGroupContent() {
        let resource : Resource? = simpleTableParser.votable?.resources?.first;
        XCTAssertTrue(resource?.tables?.first!.groups?.first!.params?.count == 2, "Missing groups in table");
        println("\(simpleTableParser.votable!.voTableString())")
    }

}
