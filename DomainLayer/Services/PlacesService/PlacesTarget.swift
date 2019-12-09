//
//  PlacesTarget.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

enum PlacesTarget {
    case getPlaceCategories(_ args: GetPlaceCategoriesArgs)
    case getPlaces(_ args: GetPlacesArgs)
}

extension PlacesTarget: RequestTarget {

    var baseURL: String {
        return ServerConfiguration.placesBaseURL
    }

    var route: Route {
        switch self {
        case .getPlaceCategories:   return .get("/places/v1/categories/places")
        case .getPlaces:            return .get("/places/v1/discover/explore")
        }
    }

    var params: [String : Any]? {
        switch self {
        case .getPlaceCategories(let args):
            return [
                "at": "\(args.latitude),\(args.longitude)"
            ]

        case .getPlaces(let args):
            var categories: String = ""
            for category in args.categories {
                categories.append(category.id)
                if category != args.categories.last {
                    categories.append(",")
                }
            }
            return [
                "at"    : "\(args.latitude),\(args.longitude)",
                "cat"   : categories
            ]
        }
    }

}
