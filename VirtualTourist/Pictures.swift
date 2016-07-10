//
//  Pictures.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 10/07/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import Foundation
import UIKit

class Pictures: NSObject {
    var pictures: [UIImage] = [UIImage]()

    override init() {
        super.init()
    }

    class func sharedInstance() -> Pictures {
        struct Singleton {
            static var sharedInstance = Pictures()
        }
        return Singleton.sharedInstance
    }
}