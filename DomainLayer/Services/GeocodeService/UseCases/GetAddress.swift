//
//  GetAddress.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

public class GetAddress: UseCase<GetAddressArgs, CurrentAddress> {

    private let service = GeocodeService()
    
    override func build(with args: GetAddressArgs, completion: ((Result<CurrentAddress, Error>) -> Void)?) {
        return service.getCurrentAddress(args, completion: completion)
    }
}

public struct GetAddressArgs {
    public let latitude: Double
    public let longitude: Double
    public let radius: Double

    public init(latitude: Double, longitude: Double, radius: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
}
