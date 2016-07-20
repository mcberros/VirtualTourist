//
//  Pin.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 10/07/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity Pin")
        }
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as! Double, longitude: longitude as! Double)
    }
}
