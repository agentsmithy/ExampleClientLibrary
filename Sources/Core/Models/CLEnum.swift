//
//  CLEnum.swift
//  ExampleClientLibrary
//
//  Created by James Reeve on 8/2/18.
//  Copyright © 2018 James Reeve. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 * A CLEnum is a base clase for a Java-like enum object.  While Objective-C does
 * support the `typedef enum` construct, it is represented as an integer , which
 * presents challenges when marshalling to/from the MAS layer.  The MAS layer will
 * send the Java literal version of its enum, so we need some way of converting
 * that into an object in the client library.
 *
 * An example of how to create an enum is as follows:
 *
 *    @interface CLCountry : CLEnum
 *    +(CLCountry *)au;
 *    +(CLCountry *)nz;
 *    @end
 *
 *    @implementation CLCountry
 *    +(CLCountry *)au { return [super enumForLiteral:@"AU"]; }
 *    +(CLCountry *)nz { return [super enumForLiteral:@"NZ"]; }
 *    @end
 */

// Object Mapper Transform

public func enumGenericTransform<T: CLEnum>() -> TransformOf<T, String> {
    return TransformOf(fromJSON: { (value: String?) -> T? in
        // transform value from String? to CLEnum<T>?
        
        if let value = value {
            return T(value)
        }
        return nil
    },
                       toJSON: { (value: T?) -> String? in
                        // transform value from CLEnum<T>? to String?
                        if let value = value {
                            return value.literal
                        }
                        return nil
    })
}

// comparitors

public func == (lhs: CLEnum, rhs: CLEnum) -> Bool {
    
    return lhs.literal.uppercased() == rhs.literal.uppercased()
}

public func != (lhs: CLEnum, rhs: CLEnum) -> Bool {
    return !(lhs.literal.uppercased() == rhs.literal.uppercased())
}

public func == (lhsOptional: CLEnum?, rhsOptional: CLEnum?) -> Bool {
    
    // if both can be unwrapped, compare using concrete comparitor
    if let lhs = lhsOptional, let rhs = rhsOptional {
        return lhs == rhs
    }
    // if lhsOptional OR rhsOptional are not nil, comparitor fails
    // if lhsOptional OR rhsOptional are not nil, comparitor fails
    // note we don't use 'if lhsOptional != nil' as that's just a cyclical reference to these same comparitors
    if let _ = lhsOptional { // swiftlint:disable:this unused_optional_binding
        return false
    }
    if let _ = rhsOptional { // swiftlint:disable:this unused_optional_binding
        return false
    }
    // default case is when both sides are nil, in which case nil==nil, return true
    return true
}

public func != (lhsOptional: CLEnum?, rhsOptional: CLEnum?) -> Bool {
    
    return !(lhsOptional == rhsOptional)
}

open class CLEnum: NSObject {
    
    /**
     * The literal value that will be marshalled over the wire for this enum value
     */
    open var literal: String
    
    /**
     * Fetches the existing enum for the passed literal. If there is not one already
     * created, it will create one, store it for later references, and return it.
     * This is *not*  meant to be called from application code.  It is meant to be
     * called from exactly two places:  1) in the implementation of CLEnum subclasses
     * when definining the fixed list of enum values, and 2) in the unmarshalling
     * framework when it needs to convert the JSON value into a singleton enum instance.
     *
     * In the Java world, once defined, an enum list is totally fixed and cannot be
     * added to, however, this class will happily return new instances of enum values
     * if you call this method with new literal values.  Don't do this!  The correct
     * way to get an enum value is to call a static method on a concrete subclass of
     * CLEnum (see the `CLCountry` example in the header of this class)
     *
     * @param literal The string literal that represents this enum. Must be unique within each subclass of CLEnum
     * @return The enum value for the passed literal.
     */
    
    public required init(_ literal: String) {
        // super.init()
        self.literal = literal
    }
    
    static var allEnumDictionaries: [String: [String: AnyObject]]?
    
    open override var hash: Int {
        return String(describing: self).hash ^ self.literal.hash
    }
    
    open override var description: String {
        return self.literal
    }
    
    /**
     * Returns whether this enum is equal to the passed enum
     */
    
    open func compare(toEnum otherEnum: CLEnum) -> ComparisonResult {
        // fortunately, because the value is stored as a string we can just piggy-back
        // on the native string comparison
        return self.literal.uppercased().compare(otherEnum.literal.uppercased())
    }
    
    open override func isEqual(_ object: Any?) -> Bool {
        if let clEnum = object as? CLEnum {
            return self.isEqual(toEnum: clEnum)
        }
        return false
    }
    
    open func isEqual(toEnum otherEnum: CLEnum) -> Bool {
        let comparisonResult: ComparisonResult = self.compare(toEnum: otherEnum)
        return comparisonResult == ComparisonResult.orderedSame ? true : false
    }
    
    open static func enumInstance(forLiteral literal: String) -> Self {
        return self.enumInstance(forLiteral: literal, withType: self)
    }
    
    private static func enumInstance<T>(forLiteral literal: String, withType _: T.Type) -> T {
        // With Swift implementation we cannot retrieve an object from our enumDictionary Dictionary and have the type correctly set to 'Self'
        // To workaround in initial implementation we create a new object for the 'Self' type and if an object exists in the database we update the only attribute (literal)
        
        // This is not memory-friendly ( as objects are being constantly recreated)
        // TODO: implement more memeory friendly version
        
        // make sure the master dictionary has been created
        if self.allEnumDictionaries == nil {
            self.allEnumDictionaries = Dictionary()
        }
        
        // make sure the dictionary that contains
        let enumClassName: String = String(describing: self)
        var enumDictionary = allEnumDictionaries?[enumClassName]
        
        if enumDictionary == nil {
            enumDictionary = Dictionary()
            //            allEnumDictionaries?[enumClassName] = enumDictionary
        }
        
        if let savedEnumInstance = enumDictionary?[literal] as? T {
            return savedEnumInstance
        } else {
            let enumInstance = self.init(literal)
            enumDictionary?[literal] = enumInstance
            allEnumDictionaries?[enumClassName] = enumDictionary
            return enumInstance as! T // swiftlint:disable:this force_cast
        }
    }
}

