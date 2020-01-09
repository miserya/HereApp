//
//  GeocodeService.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Combine

final class GeocodeService {

    func getCurrentAddress(_ args: GetAddressArgs) -> AnyPublisher<CurrentAddress, Error> {
        NetworkingManager.default.request(GeocodeTarget.currentAddress(args))
            .tryMap({ (response: CurrentAddressResponse) -> CurrentAddress in
                if let address = response.addresses.first {
                    return address
                } else {
                    throw DomainLayerError.emptyResponse
                }
            })
            .eraseToAnyPublisher()
    }
}
