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
        static let BaseParseURL = "https://api.parse.com/"
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }

    struct Methods {
        static let GetStudentLocationsMethod = "1/classes/StudentLocation"
    }

    struct ParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
    }

    struct ParameterValues {
        static let AscendingUpdatedAt = "-updatedAt"
    }
}