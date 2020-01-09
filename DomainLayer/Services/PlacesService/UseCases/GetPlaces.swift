//
//  GetPlaces.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Combine

public class GetPlaces: UseCase<GetPlacesArgs, Pagination<Place>> {

    private let service = PlacesService()

    override func build(with args: GetPlacesArgs) -> AnyPublisher<Pagination<Place>, Error> {
        service.getPlaces(args)
    }
}

public struct GetPlacesArgs {
    public let latitude: Double
    public let longitude: Double
    public let categories: [PlaceCategory]

    public init(latitude: Double, longitude: Double, categories: [PlaceCategory]) {
        self.latitude = latitude
        self.longitude = longitude
        self.categories = categories
    }
}
