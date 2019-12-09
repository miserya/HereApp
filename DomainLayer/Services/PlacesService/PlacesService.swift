//
//  PlacesService.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

class PlacesService {

    func getPlaceCategories(_ args: GetPlaceCategoriesArgs, completion: ((Result<[PlaceCategory], Error>) -> Void)?) {
        NetworkingManager.default.request(PlacesTarget.getPlaceCategories(args)) { (result: Result<PlaceCategoriesResponse, Error>) in
            completion?(result.map({ return $0.items }))
        }
    }

    func getPlaces(_ args: GetPlacesArgs, completion: ((Result<Pagination<Place>, Error>) -> Void)?) {
        NetworkingManager.default.request(PlacesTarget.getPlaces(args), completion: completion)
    }
}
