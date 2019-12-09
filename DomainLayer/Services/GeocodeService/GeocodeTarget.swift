//
//  GeocodeTarget.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

enum GeocodeTarget {
    case currentAddress(_ args: GetAddressArgs)
}

extension GeocodeTarget: RequestTarget {

    var baseURL: String {
        return ServerConfiguration.geocoderBaseURL
    }

    var route: Route {
        switch self {
        case .currentAddress:
            return .get("/6.2/reversegeocode.json")
        }
    }

    var params: [String : Any]? {
        switch self {
        case .currentAddress(let args):
            return [
                "prox": "\(args.latitude),\(args.longitude), \(args.radius)",
                "mode": "retrieveAddresses",
                "maxresults": 1,
                "gen": "9"
            ]
        }
    }

}
