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

typealias Description = String

// "The VALUES element may contain MIN and MAX elements, and it may contain OPTION elements; the latter may itself
// contain more OPTION elements, so that a hierarchy of keyword-values pairs can be associated with each field."
struct Values {
    var ID : String
    var type : String
    var null : String
    var ref : String
}

// "The role of the LINK element is to provide pointers to external resources through a URI. In VOTable, the LINK element 
// may be part of a RESOURCE, TABLE, GROUP, FIELD or PARAM element"
struct Link {
    var ID : String
    var content_role : String
    var content_type : String
    var title : String
    var value : String
    var href : String
}

// "All three MIN, MAX and OPTION sub-elements store their value corresponding to the minimum, maximum, or 
// ``special value'' in a value attribute."
protocol Value {
    var value : String { get }
    var inclusive: Bool { get }
    var null: String { get }
    init(value: String!, inclusive: Bool?, null: String?)
}

struct Min: Value {
    let value : String
    let inclusive: Bool
    let null: String
    
    init(value: String!, inclusive: Bool?, null: String?) {
        self.value = value
        self.inclusive = inclusive!
        self.null = null!
    }
}

struct Max: Value {
    let value : String
    let inclusive: Bool
    let null: String
    
    init(value: String!, inclusive: Bool?, null: String?) {
        self.value = value
        self.inclusive = inclusive!
        self.null = null!
    }
}

struct Option {
    let value: String
    let name: String?
    let null: String?
    
    init(value: String!, name: String?, null: String?) {
        self.value = value
        self.name = name!
        self.null = null!
    }
}

class FieldRef {
    var ref: String!
    var ucd: String?
    var utype: String?
}

class ParamRef {
    var ref: String!
    var ucd: String?
    var utype: String?
}

class Field {
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
    
    init (name: String!, datatype: Primitive!) {
        self.name = name
        self.datatype = datatype
    }
}

class Param : Field {
    var value: String!
    
    init (name: String!, datatype: Primitive!, value: String!) {
        super.init(name: name, datatype: datatype)
        self.name = name
        self.datatype = datatype
        self.value = value
    }
}

// "The GROUP element is used to group together a set of FIELDs and PARAMs which are logically connected, like a value
// and its error. The FIELDs are always defined outside any group, and the GROUP designates its member fields via 
// FIELDref elements."
class Group {
    var ID: String?
    var name: String?
    var ref: String?
    var ucd: String?
    var utype: String?
}

// "The FITS format for binary tables [2] is in widespread use in astronomy, and its structure has had a major influence
// on the VOTable specification. Metadata is stored in a header section, followed by the data. The metadata is 
// essentially equivalent to the metadata of the VOTable format. One important difference is that VOTable does not 
// require specification of the number of rows in the table, an important advantage if the table is being created 
// dynamically from a stream."
struct FITS {
    var extnum: String?
}


class Stream {
    var type: String?
    var href: String?
    var actuate: String?
    var encoding: String?
    var expires: String?
    var rights: String?
}

// Overriding setter to force INFO to always gace datatype=char, and arraysize="*"
class Info: Param {
    override var datatype: Primitive! {
        get { return .char }
        set {}
    }
    override var arraysize: String! {
        get { return "*" }
        set {}
    }
    
    init (name: String!, value: String!) {
        super.init(name: name, datatype: .char, value: value)
    }
}

enum DataFormat {
    case TABLEDATA
    case FITS
    case BINARY
    case BINARY2
}

class Data {
    let format: DataFormat!
    let content: AnyObject!
    init() {
        self.format = nil
        self.content = nil
    }
}

// "The TABLEDATA element is a way to build the table in pure XML, and has the advantage that XML tools can manipulate
// and present the table data directly. The TABLEDATA element contains TR elements, which in turn contain TD elements —
// i.e. the same conventions as in HTML."
struct TD {
    var encoding: String?
    var value: String?
}

struct TR {
    var ID: String?
    var cells: [TD]?
}

class TableData {
    var rows: [TR]?
}


// "The TABLE element represents the basic data structure in VOTable; it comprises a description of the table structure 
// (the metadata) essentially in the form of PARAM and FIELD elements, followed by the values of the described fields 
// in a DATA element. The TABLE element is always contained in a RESOURCE element."
class Table {
    var ID: String?
    var name: String?
    var ucd: String?
    var utype: String?
    var ref: String?
    var nrows: String?
    
    var description: Description?

    var params: [Param]?
    var fields: [Field]?
    var groups: [Group]?
}

class Resource {
    var ID: String?
    var name: String?
    var type: String?
    var utype: String?
    
    var description: Description?
    
    var infos: [Info]?
    var params: [Param]?
    var groups: [Group]?
    var links: [Link]?
}

// Borrowed from https://www.weheartswift.com/swift-objc-magic/
extension NSObject {
    func propertyNames() -> [String] {
        var names: [String] = []
        var count: UInt32 = 0
        // Uses the Objc Runtime to get the property list
        var properties = class_copyPropertyList(classForCoder, &count)
        for var i = 0; i < Int(count); ++i {
            let property: objc_property_t = properties[i]
            let name: String = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding) as! String
            names.append(name)
        }
        free(properties)
        return names
    }
}

// "A VOTable document contains one or more RESOURCE elements, each of these providing a description and the data values 
// of some logically independent data structure."
class VOTable: NSObject {
    var attributes: Dictionary<String, String> = [:]

    var ID: String?
    var version: String?
    var resources: [Resource]?
    var infos: [Info]?
    var params: [Param]?
    var groups: [Group]?

    convenience init(rawAttributes: [NSObject : AnyObject]?) {
        self.init()
        
        if let rawAttr = rawAttributes {
            let propNamesSet = Set(self.propertyNames())

            for (keyAny, valueAny) in rawAttr {
                let keyString = keyAny as! String
                let valueString = valueAny as! String
                
                if propNamesSet.contains(keyString) {
                    self.setValue(valueString, forKey:keyString)
                }
                else {
                    self.attributes[keyString] = valueString
                }
            }
        }

    }    
}
