//
//  CLAlertMessageResponse.swift
//  ExampleClientLibrary
//
//  Created by James Reeve on 8/2/18.
//  Copyright © 2018 James Reeve. All rights reserved.
//

import Foundation

public class CLAlertMessageResponse: NSObject {
     /** The HTTP status code (eg. 200, 403) to cater for clients that are not easily able to retrieve the HTTP response code */
    public var statusCode: Double?
    
    /** A human-readable message of the above messageCode. Designed for end-user consumption */
    public var message: String?
    
    /** The actual resource being returned.  It could be an array of, say, accounts or a single account or a contract, etc */
    public var data: Any?
}
