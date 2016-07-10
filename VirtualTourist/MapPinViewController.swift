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
    var tapRecognizer: UITapGestureRecognizer? = nil

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        annotations = [MKPointAnnotation]()
        //Add GestureRecognizer to Drop a pin
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        longPressGestureRecognizer!.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
        mapView.delegate = self
        //Get Pins from DB
    }
}

extension MapPinViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "Pin"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.blueColor()
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let photoAlbumViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoAlbumID") as! PhotoAlbumViewController

        photoAlbumViewController.latitude = view.annotation?.coordinate.latitude
        photoAlbumViewController.longitude = view.annotation?.coordinate.longitude
//        photoAlbumViewController.coordinate = view.annotation?.coordinate
        self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }
}

extension MapPinViewController {
    func addAnnotation(recognizer: UIGestureRecognizer) {
        let touchPoint = recognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        //Persist pin
        annotations!.append(annotation)
    }
}


