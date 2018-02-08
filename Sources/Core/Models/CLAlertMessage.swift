//
//  CLAlertMessage.swift
//  ExampleClientLibrary
//
//  Created by James Reeve on 8/2/18.
//  Copyright © 2018 James Reeve. All rights reserved.
//

import Foundation
import ObjectMapper

/**
 * Identifies the the frequency that the alert message is to be displayed
 * AMPAlertMessageFrequencyOnce - displayed once for this app instance
 * AMPAlertMessageFrequencyAlways - displayed every time (always) for this app instance
 */

open class AlertMessageFrequency: CLEnum {
    
    /** Used to specify that an alert is only to be shown once */
    open class func showOnce() -> AlertMessageFrequency {
        return AlertMessageFrequency.enumInstance(forLiteral: "SHOW_ONCE")
    }
    
    /** Used to specify that an alert is to be shown every time (always) */
    open class func showEverytime() -> AlertMessageFrequency {
        return AlertMessageFrequency.enumInstance(forLiteral: "SHOW_EVERYTIME")
    }
}

public let alertMessageFrequencyTransform = TransformOf<AlertMessageFrequency, String>(fromJSON: { (value: String?) -> AlertMessageFrequency? in
    // transform value from String? to AlertMessageFrequency?
    
    if let value = value {
        return AlertMessageFrequency(value)
    }
    return nil
}, toJSON: { (value: AlertMessageFrequency?) -> String? in
    // transform value from AlertMessageFrequency? to String?
    if let value = value {
        return value.literal
    }
    return nil
})

open class AlertMessage: NSObject, StaticMappable {
    
    /** The alert message to be displayed on the device */
    public var alertMessage: String?
    
    /** Identifies the frequency that the alert message is to be displayed e.g. displayed once, displayed every time (always). */
    public var alertIndicator: AlertMessageFrequency?
    
    public func mapping(map: Map) {
        
        self.alertMessage <- map["alertMessage"]
        self.alertIndicator <- map["alertIndicator"]
        self.alertIndicator <- (map["alertIndicator"], alertMessageFrequencyTransform)
    }
    
    public static func objectForMapping(map _: Map) -> BaseMappable? {
        return AlertMessage()
    }
}
