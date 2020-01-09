//
//  PlacesService.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Combine

class PlacesService {

    func getPlaceCategories(_ args: GetPlaceCategoriesArgs) -> AnyPublisher<[PlaceCategory], Error> {
        NetworkingManager.default.request(PlacesTarget.getPlaceCategories(args))
            .map({ (response: PlaceCategoriesResponse) in
                return response.items
            })
            .eraseToAnyPublisher()
    }

    func getPlaces(_ args: GetPlacesArgs) -> AnyPublisher<Pagination<Place>, Error> {
        NetworkingManager.default.request(PlacesTarget.getPlaces(args))
    }
}
