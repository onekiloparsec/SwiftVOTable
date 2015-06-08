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

protocol VOTableElementSpecification {
    func voTableElementValueName() -> String?
    func voTableElementChildrenNames() -> Array<String>?
}

struct VOTableTranslations {
    static let PropertyAliases = [ "ID": "id", "voDescription": "description" ]
}

public class VOTableElement: NSObject {
    public var customAttributes: Dictionary<String, String> = [:]

    required public init(_ rawAttributes: [NSObject : AnyObject]?) {
        super.init()
        
        if let rawAttr = rawAttributes {
            let propNamesSet = Set(self.propertyNames())
            
            for (keyAny, valueAny) in rawAttr {
                let keyString = keyAny as! String
                let valueString = valueAny as! String
                
                if propNamesSet.contains(keyString) {
                    self.setValue(valueString, forKey:keyString)
                }
                else {
                    self.customAttributes[keyString] = valueString
                }
            }
        }
    }
    
    public func setNewElement(newElement: VOTableElement, forPropertyName propertyName: String) {
        let propertyPluralName = propertyName.plural()
        
        if (self.hasProperty(propertyName) == true) {
            // Current element has property of that name. Set the property, and move the 'currentElement' cursor to the new one.
            self.setValue(newElement, forKey:propertyName)
        }
        else if (self.hasProperty(propertyPluralName) == true) {
            // Current element has a plural property of that name.
            if var props : [NSObject] = self.valueForKey(propertyPluralName) as? [NSObject] {
                // We already have a collection type for that property. Append the new element to it.
                props.append(newElement)
            }
            else {
                // Set the property to a list containing that element.
                self.setValue([newElement], forKey:propertyPluralName)
            }
        }
        else {
            // Deal with error.
        }
    }
    
    public func voTableString() -> String {
        let className = NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!.uppercaseString
        
        var xml = String()

        // Element opening
        xml += "<\(className)"

        // Atttributes
        var propertyNamesSet: Set<String> = Set(self.propertyNames())

        if let object = self as? VOTableElementSpecification {
            if let valueName = object.voTableElementValueName() {
                propertyNamesSet.remove(valueName)
            }
            
            if let childrenNames = object.voTableElementChildrenNames() {
                for childrenName in childrenNames {
                    propertyNamesSet.remove(childrenName)
                }
            }
        }

        for propertyName: String in Array(propertyNamesSet) {
            if let value: String = self.valueForKey(propertyName) as? String {
                xml += " \(propertyName)=\"\(value)\""
            }
        }
        
        if self.customAttributes.count > 0 {
            for (key, value) in self.customAttributes {
                xml += " \(key)=\"\(value)\""
            }
        }

        xml += ">\n"
        
        if let object = self as? VOTableElementSpecification {
            if let valueName = object.voTableElementValueName() {
                if let value : String = self.valueForKey(valueName) as? String {
                    xml += "\(value)"
                }
            }
            
            if let childrenNames = object.voTableElementChildrenNames() {
                for childrenName in childrenNames {
                    if let childrenValues : Array<AnyObject> = self.valueForKey(childrenName) as? Array<AnyObject> {
                        for childrenValue in childrenValues {
                            if childrenValue is VOTableElement {
                                xml += childrenValue.voTableString()
                            }
                        }
                    }
                }
            }
        }

        // Element closing
        xml += "</\(className)>\n"
        
        return xml
    }
}

// "The VALUES element may contain MIN and MAX elements, and it may contain OPTION elements; the latter may itself
// contain more OPTION elements, so that a hierarchy of keyword-values pairs can be associated with each field."
public struct Values {
    var ID : String
    var type : String
    var null : String
    var ref : String
}

// "The role of the LINK element is to provide pointers to external resources through a URI. In VOTable, the LINK element 
// may be part of a RESOURCE, TABLE, GROUP, FIELD or PARAM element"
public struct Link {
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

public class FieldRef {
    var ref: String!
    var ucd: String?
    var utype: String?
}

public class ParamRef {
    var ref: String!
    var ucd: String?
    var utype: String?
}

public class Field {
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

public class Param : Field {
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
public class Group {
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

// "The TABLEDATA element is a way to build the table in pure XML, and has the advantage that XML tools can manipulate
// and present the table data directly. The TABLEDATA element contains TR elements, which in turn contain TD elements —
// i.e. the same conventions as in HTML."
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


// "The TABLE element represents the basic data structure in VOTable; it comprises a description of the table structure
// (the metadata) essentially in the form of PARAM and FIELD elements, followed by the values of the described fields 
// in a DATA element. The TABLE element is always contained in a RESOURCE element."
public class Table: VOTableElement {
    var ID: String?
    var name: String?
    var ucd: String?
    var utype: String?
    var ref: String?
    var nrows: String?
    
    var voDescription: Description?

    var params: [Param]?
    var fields: [Field]?
    var groups: [Group]?
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
}

// "A VOTable document contains one or more RESOURCE elements, each of these providing a description and the data values 
// of some logically independent data structure."
public class VOTable: VOTableElement, VOTableElementSpecification {
    public var ID: String?
    public var version: String?

    public var infos: [Info]?
    public var params: [Param]?
    public var groups: [Group]?
    
    public var resources: [Resource]?
    
    func voTableElementValueName() -> String? { return nil }
    func voTableElementChildrenNames() -> Array<String>?  {
        return ["infos", "params", "groups", "resources"]
    }
}
