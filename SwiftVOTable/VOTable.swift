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

import Foundation

// "The VALUES element may contain MIN and MAX elements, and it may contain OPTION elements; the latter may itself
// contain more OPTION elements, so that a hierarchy of keyword-values pairs can be associated with each field."
public struct Values {
    var ID : String
    var type : String
    var null : String
    var ref : String
}


// "All three MIN, MAX and OPTION sub-elements store their value corresponding to the minimum, maximum, or 
// ``special value'' in a value attribute."
protocol Value {
    var value : String { get }
    var inclusive: Bool { get }
    var null: String { get }
    init(value: String!, inclusive: Bool?, null: String?)
}

public struct Min: Value {
    let value : String
    let inclusive: Bool
    let null: String
    
    init(value: String!, inclusive: Bool?, null: String?) {
        self.value = value
        self.inclusive = inclusive!
        self.null = null!
    }
}

public struct Max: Value {
    let value : String
    let inclusive: Bool
    let null: String
    
    init(value: String!, inclusive: Bool?, null: String?) {
        self.value = value
        self.inclusive = inclusive!
        self.null = null!
    }
}

public struct Option {
    let value: String
    let name: String?
    let null: String?
    
    init(value: String!, name: String?, null: String?) {
        self.value = value
        self.name = name!
        self.null = null!
    }
}

// "The FITS format for binary tables [2] is in widespread use in astronomy, and its structure has had a major influence
// on the VOTable specification. Metadata is stored in a header section, followed by the data. The metadata is 
// essentially equivalent to the metadata of the VOTable format. One important difference is that VOTable does not 
// require specification of the number of rows in the table, an important advantage if the table is being created 
// dynamically from a stream."
public struct FITS {
    var extnum: String?
}


public class Stream {
    var type: String?
    var href: String?
    var actuate: String?
    var encoding: String?
    var expires: String?
    var rights: String?
}

// Overriding setter to force INFO to always have datatype=char, and arraysize="*"
public class Info: Param {
    override public var datatype: Primitive! {
        get { return .char }
        set {}
    }
    override public var arraysize: String! {
        get { return "*" }
        set {}
    }
    
//    init (name: String!, value: String!) {
//        super.init(name: name, datatype: .char, value: value)
//    }
}

public enum DataFormat {
    case TABLEDATA
    case FITS
    case BINARY
    case BINARY2
}

public class Data {
    let format: DataFormat!
    let content: AnyObject!
    init() {
        self.format = nil
        self.content = nil
    }
}

/**
*  "The TABLEDATA element is a way to build the table in pure XML, and has the advantage that XML tools can manipulate
*  and present the table data directly. The TABLEDATA element contains TR elements, which in turn contain TD elements —
*  i.e. the same conventions as in HTML."
*/
public struct TD {
    var encoding: String?
    var value: String?
}

public struct TR {
    var ID: String?
    var cells: [TD]?
}

public class TableData {
    var rows: [TR]?
}


// ************

public class FIELDRef : VOTableElement {
    public var ref: String!
    public var ucd: String?
    public var utype: String?
}

public class PARAMRef : VOTableElement {
    public var ref: String!
    public var ucd: String?
    public var utype: String?
}

/**
*  "The role of the LINK element is to provide pointers to external resources through a URI. In VOTable, the LINK element
*  may be part of a RESOURCE, TABLE, GROUP, FIELD or PARAM element."
*/
public class Link : VOTableElement {
    public var ID : String?
    public var content_role : String?
    public var content_type : String?
    public var title : String?
    public var value : String?
    public var href : String?
}

public class Description : VOTableElement {
    public var value: String?
}

public class Field : VOTableElement {
    public var ID: String?
    public var name: String!
    public var datatype: Primitive!
    public var arraysize: String?
    public var width: Int?
    public var precision: Int?
    public var xtype: String?
    public var unit: String?
    public var ucd: String?
    public var utype: String?
    public var ref: String?
    
    public var voDescription: Description?
    
    //    init (name: String!, datatype: Primitive!) {
    //        self.name = name
    //        self.datatype = datatype
    //    }
    //
    //    required public init(_ rawAttributes: [NSObject : AnyObject]?) {
    //        fatalError("init has not been implemented")
    //    }
}

public class Param : Field {
    public var value: String!

    //    init (name: String!, datatype: Primitive!, value: String!) {
    //        super.init(name: name, datatype: datatype)
    //        self.name = name
    //        self.datatype = datatype
    //        self.value = value
    //    }
    //
}

/**
*  "The GROUP element is used to group together a set of FIELDs and PARAMs which are logically connected, like a value
*  and its error. The FIELDs are always defined outside any group, and the GROUP designates its member fields via
*  FIELDref elements."
*/
public class Group : VOTableElement {
    public var ID: String?
    public var name: String?
    public var ref: String?
    public var ucd: String?
    public var utype: String?
    
    public var params: [Param]?
}

/**
*  "The TABLE element represents the basic data structure in VOTable; it comprises a description of the table structure
*  (the metadata) essentially in the form of PARAM and FIELD elements, followed by the values of the described fields
*  in a DATA element. The TABLE element is always contained in a RESOURCE element."
*/
public class Table: VOTableElement {
    public var ID: String?
    public var name: String?
    public var ucd: String?
    public var utype: String?
    public var ref: String?
    public var nrows: String?
    
    public var voDescription: Description?

    public var params: [Param]?
    public var fields: [Field]?
    public var groups: [Group]?
}

public class Resource: VOTableElement {
    public var ID: String?
    public var name: String?
    public var type: String?
    public var utype: String?
    
    public var voDescription: Description?
    
    public var infos: [Info]?
    public var params: [Param]?
    public var groups: [Group]?
    public var links: [Link]?
    
    public var tables: [Table]?
}

/**
*  "A VOTable document contains one or more RESOURCE elements, each of these providing a description and the data values 
*  of some logically independent data structure."
*/
public class VOTable: VOTableElement {
    public var ID: String?
    public var version: String?

    public var infos: [Info]?
    public var params: [Param]?
    public var groups: [Group]?
    
    public var resources: [Resource]?
}
