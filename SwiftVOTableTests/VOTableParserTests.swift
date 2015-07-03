//
//  VOTableParserTests.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 04/04/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//

import UIKit
import XCTest
import SwiftVOTable

class VOTableParserTests: XCTestCase {
    
    var simpleTableParser : VOTableParser?

    override func setUp() {
        super.setUp()
        
        println(NSBundle.mainBundle().resourcePath)
        let path = NSBundle(forClass: self.dynamicType).pathForResource("OfficialVOTableDocSimpleTable", ofType: "txt")
        let simpleTableXMLString = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
        simpleTableParser = VOTableParser(xmlString: simpleTableXMLString)
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

    func testInitParserWithValidSimpleString() {
        XCTAssertNotNil(simpleTableParser, "Parser should be initialised.")
        XCTAssertTrue(simpleTableParser?.parse() == true, "Parser should return true")
    }
    
    func testParserSimpleStringVOTableElement() {
        simpleTableParser?.parse()
        XCTAssertNotNil(simpleTableParser?.votable, "One must have a VOTable instance.");
        XCTAssertNotNil(simpleTableParser?.votable?.customAttributes, "One must have an attribute instance attached to the table.");
        XCTAssertTrue(simpleTableParser?.votable?.version == "1.3", "Version of VOTable is wrong.")
    }

    func testParserSimpleStringVOTableResources() {
        simpleTableParser?.parse()
        XCTAssertNotNil(simpleTableParser?.votable?.resources, "One should find resources")
        XCTAssertTrue(simpleTableParser?.votable?.resources?.count == 1, "One should find one resource.")
        XCTAssertTrue(simpleTableParser?.votable?.resources?.first!.tables?.count == 1, "One should find one table in the resource.")
    }
    
    func testParserSimpleStringVOTableResourceTableFields() {
        simpleTableParser?.parse()
        var table = simpleTableParser?.votable?.resources?.first?.tables?.first
        XCTAssertNotNil(table?.fields, "Missing fields in table")
        XCTAssertNotNil(table?.data, "Missing data in table")
        XCTAssertNotNil(table?.data?.tableData, "Missing tableData in table data.")
    }
    
    func testParserSimpleStringVOTableFieldsAndCells() {
        simpleTableParser?.parse()        
        var fields = simpleTableParser?.votable?.resources?.first?.tables?.first?.fields
        var rows = simpleTableParser?.votable?.resources?.first?.tables?.first?.data?.tableData?.rows
        for row in rows! {
            if let cells = row.cells {
                XCTAssertTrue(cells.count == fields?.count, "Different number of fields and row cells?")
                for i in 0..<cells.count {
                    var cell = cells[i]
                    XCTAssertEqual(cell.field!, fields![i], "Field not set corrcetly.")
                }
            }
        }
    }
}

