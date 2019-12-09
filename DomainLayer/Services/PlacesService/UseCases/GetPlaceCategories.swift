//
//  GetPlaceCategories.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

public class GetPlaceCategories: UseCase<GetPlaceCategoriesArgs, [PlaceCategory]> {

    private let service = PlacesService()

    override func build(with args: GetPlaceCategoriesArgs, completion: ((Result<[PlaceCategory], Error>) -> Void)?) {
        service.getPlaceCategories(args, completion: completion)
    }
}

public struct GetPlaceCategoriesArgs {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
