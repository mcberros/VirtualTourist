//
//  FlickrApiConveniences.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 10/07/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import Foundation
import UIKit

extension FlickrApiClient {
    func getImageFromFlickrBySearch(boundingBoxString: String, completionHandler: (success: Bool, photosArray: [[String: AnyObject]],errorString: String?) -> Void) {

        let session = NSURLSession.sharedSession()

        let methodArguments = [
            "method": FlickrApiClient.Methods.SearchPhotos,
            "api_key": FlickrApiClient.Constants.ApiKey,
            "bbox": boundingBoxString,
            "safe_search": FlickrApiClient.ParameterValues.SafeSearch,
            "extras": FlickrApiClient.ParameterValues.Extras,
            "format": FlickrApiClient.ParameterValues.Format,
            "nojsoncallback": FlickrApiClient.ParameterValues.NoJsonCallback,
            "per_page": FlickrApiClient.ParameterValues.PerPage
        ]

        let urlString = FlickrApiClient.Constants.BaseURL + escapedParameters(methodArguments)
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

            if totalPhotos > 0 {

                /* GUARD: Is the "photo" key in photosDictionary? */
                guard let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find key 'photo' in \(photosDictionary)")
                    return
                }

                completionHandler(success: true, photosArray: photosArray, errorString: "")
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