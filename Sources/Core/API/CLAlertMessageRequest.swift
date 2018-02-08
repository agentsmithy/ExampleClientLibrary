//
//  CLAlertMessageRequest.swift
//  ExampleClientLibrary
//
//  Created by James Reeve on 8/2/18.
//  Copyright © 2018 James Reeve. All rights reserved.
//

import Foundation

public class CLAlertMessageRequest: NSObject {
    public func requestName() -> String {
        return "CLAlertMessageReequest"
    }
    
    public func execute() -> CLAlertMessageResponse {
        //execute the request
        return CLAlertMessageResponse()
    }
}
