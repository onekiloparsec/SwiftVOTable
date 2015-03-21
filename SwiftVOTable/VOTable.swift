//
//  VOTable.swift
//  SwiftVOTable
//
//  Created by Cédric Foellmi on 21/03/15.
//  Copyright (c) 2015 onekiloparsec. All rights reserved.
//
//
// --- Editor width: 120 -----------------------------------------------------------------------------------------------
//
// 2015-03-21
// Working with http://www.ivoa.net/documents/VOTable/20130920/REC-VOTable-1.3-20130920.html#ToC16
// VOTable Format Definition Version 1.3
// IVOA Recommendation 2013-09-20

import Cocoa

enum Primitive {
    case boolean
    case bit
    case unsignedByte
    case short
    case int
    case long
    case char
    case unicodeChar
    case float
    case double
    case floatComplex
    case doubleComplex
}

protocol Value {
    var value : String { get }
    var inclusive: Bool { get }
    var null: String { get }
    init(value: String!, inclusive: Bool?, null: String?)
}

struct MIN: Value {
    let value : String
    let inclusive: Bool
    let null: String
    
    init(value: String!, inclusive: Bool?, null: String?) {
        self.value = value
        self.inclusive = inclusive!
        self.null = null!
    }
}

struct MAX: Value {
    let value : String
    let inclusive: Bool
    let null: String
    
    init(value: String!, inclusive: Bool?, null: String?) {
        self.value = value
        self.inclusive = inclusive!
        self.null = null!
    }
}

struct OPTION {
    let value: String
    let name: String?
    let null: String?
    
    init(value: String!, name: String?, null: String?) {
        self.value = value
        self.name = name!
        self.null = null!
    }
}

class FIELDRef {
    var ref: String!
    var ucd: String?
    var utype: String?
}

class PARAMRef {
    var ref: String!
    var ucd: String?
    var utype: String?
}

class FIELD {
    var ID: String?
    var name: String!
    var datatype: Primitive!
    var arraysize: String?
    var width: Int?
    var precision: Int?
    var xtype: String?
    var unit: String?
    var ucd: String?
    var utype: String?
    var ref: String?
    var description: String?
}

class PARAM : FIELD {
    var value: String!
}

class GROUP {
    var ID: String?
    var name: String?
    var ref: String?
    var ucd: String?
    var utype: String?
}

class VOTable: NSObject {

}
