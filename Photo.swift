//
//  Photo.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 28/07/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    convenience init(pin: Pin, imageData: NSData, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.imageData = imageData
            self.pin = pin
        } else {
            fatalError("Unable to find Entity Photo")
        }
    }
}
