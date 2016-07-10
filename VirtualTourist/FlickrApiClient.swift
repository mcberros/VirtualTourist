//
//  FlickrApiClient.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 03/07/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import Foundation

class FlickrApiClient: NSObject {
    var session: NSURLSession

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }

    class func sharedInstance() -> FlickrApiClient {
        struct Singleton {
            static var sharedInstance = FlickrApiClient()
        }
        return Singleton.sharedInstance
    }
}
