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
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.photos.search"
    let API_KEY = "b78bc85713989c71fce367ce67a46843"
    let EXTRAS = "url_m"
    let SAFE_SEARCH = "1"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    let PER_PAGE = "10"
    let BOUNDING_BOX_HALF_WIDTH = 1.0
    let BOUNDING_BOX_HALF_HEIGHT = 1.0
    let LAT_MIN = -90.0
    let LAT_MAX = 90.0
    let LON_MIN = -180.0
    let LON_MAX = 180.0

    var pictures: [UIImage]?
    let reuseIdentifier = "cell"

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
        pictures = [UIImage]()
        photoAlbumCollectionView.dataSource = self
        photoAlbumCollectionView.delegate = self
        //If there are no photos for pin connect Flickr
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
            "per_page": PER_PAGE
        ]
        getImageFromFlickrBySearch(methodArguments)

        //If there are photos, get photos for this pin
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
            "per_page": PER_PAGE
        ]
        getImageFromFlickrBySearch(methodArguments)

    }

    func createBoundingBoxString() -> String {

        let latitude = coordinate?.latitude
        let longitude = coordinate?.longitude

        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude! - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude! - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude! + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude! + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)

        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }

    // MARK: Flickr API

    func getImageFromFlickrBySearch(methodArguments: [String : AnyObject]) {

        let session = NSURLSession.sharedSession()
        print(escapedParameters(methodArguments))
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)

        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }

            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }

            /* GUARD: Did Flickr return an error? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }

            /* GUARD: Is "photos" key in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary else {
                print("Cannot find keys 'photos' in \(parsedResult)")
                return
            }

            /* GUARD: Is the "total" key in photosDictionary? */
            guard let totalPhotos = (photosDictionary["total"] as? NSString)?.integerValue else {
                print("Cannot find key 'total' in \(photosDictionary)")
                return
            }

//            guard let perPage = (photosDictionary["perpage"] as? NSString)?.integerValue else {
//                print("Cannot find key 'perpage' in \(photosDictionary)")
//                return
//            }

            if totalPhotos > 0 {

                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }


                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]

                /* GUARD: Does our photo have a key for 'url_m'? */
                guard let imageUrlString = photoDictionary["url_m"] as? String else {
                    print("Cannot find key 'url_m' in \(photoDictionary)")
                    return
                }

                let imageURL = NSURL(string: imageUrlString)

                if let imageData = NSData(contentsOfURL: imageURL!) {
                    self.pictures?.append(UIImage(data: imageData)!)
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.defaultLabel.alpha = 0.0
//                        self.photoImageView.image = UIImage(data: imageData)
//                        self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
//                    })
                    dispatch_async(dispatch_get_main_queue()) {
                        self.photoAlbumCollectionView.reloadData()
                    }
                } else {
                    print("Image does not exist at \(imageURL)")
                }
            } else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.photoTitleLabel.text = "No Photos Found. Search Again."
//                    self.defaultLabel.alpha = 1.0
//                    self.photoImageView.image = nil
//                })
            }
        }

        task.resume()
    }

    // MARK: Escape HTML Parameters

    func escapedParameters(parameters: [String : AnyObject]) -> String {

        var urlVars = [String]()

        for (key, value) in parameters {

            /* Make sure that it is a string value */
            let stringValue = "\(value)"

            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]

        }

        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
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
        return pictures!.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.photoCellImageView.image = pictures![indexPath.item]
        cell.backgroundColor = UIColor.blackColor()
        // Configure the cell
        return cell
    }
}