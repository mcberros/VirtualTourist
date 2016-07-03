//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 30/06/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import Foundation
import MapKit

class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var pinMapView: MKMapView!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!

//    var latitude: Double?
//    var longitude: Double?
    var coordinate: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        //Center pin
        let latDelta: CLLocationDegrees = 0.1
        let longDelta: CLLocationDegrees = 0.1
        let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)

        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate!, theSpan)
        pinMapView?.setRegion(region, animated: true)

        let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate!
        pinMapView?.addAnnotation(pointAnnotation)

        //Show photoAlbum
        //If there are no photos for pin connect Flickr
        //If there are photos, get photos for this pin
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "PinPhotoAlbum"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = UIColor.redColor()
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }
}