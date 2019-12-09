//
//  GeocodeService.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

final class GeocodeService {

    func getCurrentAddress(_ args: GetAddressArgs, completion: ((Result<CurrentAddress, Error>) -> Void)?) {
        NetworkingManager.default.request(GeocodeTarget.currentAddress(args)) { (result: Result<CurrentAddressResponse, Error>) in
            switch result {
            case .success(let response):
                if let address = response.addresses.first {
                    completion?(.success(address))
                } else {
                    completion?(.failure(DomainLayerError.emptyResponse))
                }
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
