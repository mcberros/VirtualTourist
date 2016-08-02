//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 30/06/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
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
    var pin: Pin?

    var appDelegate: AppDelegate!
    var stack: CoreDataStack!

    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            // Whenever the frc changes, we execute the search
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = appDelegate.stack

        //

        let fr = NSFetchRequest(entityName: "Photo")

        fr.sortDescriptors = [NSSortDescriptor(key: "pin", ascending: true)]

        let pred = NSPredicate(format: "pin = %@", pin!)

        fr.predicate = pred

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
            managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

        fetchedResultsController?.delegate = self

        let photos = fetchedResultsController!.fetchedObjects! as? [Photo]

        //Center pin
        let latDelta: CLLocationDegrees = 0.1
        let longDelta: CLLocationDegrees = 0.1
        let theSpan: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)

        latitude = pin?.latitude as? Double
        longitude = pin?.longitude as? Double

        let coordinate = pin?.coordinate
        let region: MKCoordinateRegion = MKCoordinateRegionMake(coordinate!, theSpan)
        pinMapView?.setRegion(region, animated: true)

        let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate!
        pinMapView?.addAnnotation(pointAnnotation)

        //Show photoAlbum
        photoAlbumCollectionView.dataSource = self
        photoAlbumCollectionView.delegate = self
        //If there are no photos for pin connect Flickr

        if photos!.count == 0 {
        FlickrApiClient.sharedInstance().getImageFromFlickrBySearch(createBoundingBoxString()){(success, photosArray, errorString) in
                if success {
                    for(photoDictionary) in photosArray {
                        /* GUARD: Does our photo have a key for 'url_m'? */
                        guard let photoUrlString = photoDictionary["url_m"] as? String else {
                            print("Cannot find key 'url_m' in \(photoDictionary)")
                            return
                        }
    
                        let photoURL = NSURL(string: photoUrlString)
    
                        if let photoData = NSData(contentsOfURL: photoURL!) {
                            let photo = Photo(pin: self.pin!, imageData: photoData, context: self.stack.context)
                            self.stack.save()
                        } else {
                            print("Image does not exist at \(photoURL)")
                        }
                    }

                    dispatch_async(dispatch_get_main_queue()) {
                        self.photoAlbumCollectionView.reloadData()
                    }
                } else {
                    print(errorString)
                }
            }
        }
    }

    func createBoundingBoxString() -> String {
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude! - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude! - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude! + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude! + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)

        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }

    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
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
        return (pin!.photos?.count)!
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell

        let photo = fetchedResultsController!.objectAtIndexPath(indexPath) as! Photo

        cell.photoCellImageView.image = UIImage(data: photo.imageData!)
        cell.backgroundColor = UIColor.blackColor()

        return cell
    }
}