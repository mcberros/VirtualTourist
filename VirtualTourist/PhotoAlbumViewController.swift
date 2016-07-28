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
    let BOUNDING_BOX_HALF_WIDTH = 1.0
    let BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0

    let reuseIdentifier = "cell"

    @IBOutlet weak var pinMapView: MKMapView!
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!

    var latitude: Double?
    var longitude: Double?

    override func viewDidLoad() {
        super.viewDidLoad()
        //Center pin
        let latDelta: CLLocationDegrees = 0.1
        let longDelta: CLLocationDegrees = 0.1
        let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)

        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate, theSpan)
        pinMapView?.setRegion(region, animated: true)

        let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pinMapView?.addAnnotation(pointAnnotation)

        //Show photoAlbum
        photoAlbumCollectionView.dataSource = self
        photoAlbumCollectionView.delegate = self
        //If there are no photos for pin connect Flickr
        FlickrApiClient.sharedInstance().getImageFromFlickrBySearch(createBoundingBoxString()){(success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photoAlbumCollectionView.reloadData()
                    }
                } else {
    //                dispatch_async(dispatch_get_main_queue()){
    //                    self.showAlert(errorString!)
    //                }
                }
            }
        //If there are photos, get photos for this pin
    }

    func createBoundingBoxString() -> String {
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude! - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude! - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude! + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude! + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)

        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
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

extension PhotoAlbumViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Photos.sharedInstance().photos.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.photoCellImageView.image = Photos.sharedInstance().photos[indexPath.item]
        cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        return cell
    }
}