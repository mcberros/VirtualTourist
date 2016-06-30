//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 26/06/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import UIKit
import MapKit

class MapPinViewController: UIViewController {
    var annotations: [MKPointAnnotation]?
    var coordinate: CLLocationCoordinate2D?
    var latitude: Double?
    var longitude: Double?

    var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        annotations = [MKPointAnnotation]()
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnotation:")
        longPressGestureRecognizer!.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //Get Pins from DB
    }
}

extension MapPinViewController {
    func addAnotation(recognizer: UIGestureRecognizer) {
        let touchPoint = recognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
    }
}


