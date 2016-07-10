//
//  FlickrApiConstants.swift
//  VirtualTourist
//
//  Created by Carmen Berros on 03/07/16.
//  Copyright © 2016 mcberros. All rights reserved.
//

import Foundation

extension FlickrApiClient {

    struct Constants {
        static let BaseURL = "https://api.flickr.com/services/rest/"
        static let ApiKey = "b78bc85713989c71fce367ce67a46843"
    }

    struct Methods {
        static let SearchPhotos = "flickr.photos.search"
    }

    struct ParameterValues {
        static let SafeSearch = "1"
        static let Extras = "url_m"
        static let Format = "json"
        static let NoJsonCallback = "1"
        static let PerPage = "10"
    }
}



