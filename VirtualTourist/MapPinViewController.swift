//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 26/06/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapPinViewController: UIViewController, NSFetchedResultsControllerDelegate {
//    var annotations: [MKPointAnnotation]?
    var coordinate: CLLocationCoordinate2D?
    var latitude: Double?
    var longitude: Double?

    var longPressGestureRecognizer: UILongPressGestureRecognizer? = nil
    var tapRecognizer: UITapGestureRecognizer? = nil

    @IBOutlet weak var mapView: MKMapView!

    var appDelegate: AppDelegate!
    var stack: CoreDataStack!

    var fetchedResultsController : NSFetchedResultsController?{
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
//            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        annotations = [MKPointAnnotation]()
        //Add GestureRecognizer to Drop a pin
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "addAnnotation:")
        longPressGestureRecognizer!.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGestureRecognizer!)
        mapView.delegate = self

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stack = appDelegate.stack

        //Get Pins from DB
        let fr = NSFetchRequest(entityName: "Pin")

        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
            managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

        if let fetched = self.fetchedResultsController!.fetchedObjects as? [Pin] {
            for annotation in fetched {
                self.mapView.addAnnotation(annotation)
            }
        }
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
        self.navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }
}

extension MapPinViewController {
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }

    func addAnnotation(recognizer: UIGestureRecognizer) {
        let touchPoint = recognizer.locationInView(mapView)
        let newCoordinates = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)

        let pin = Pin(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude, context: stack.context)
        stack.save()
        self.mapView.addAnnotation(pin)
    }
}


