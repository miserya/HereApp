//
//  CurrentAddress.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

public struct CurrentAddress: Decodable {
    static public let empty = CurrentAddress(name: "")
    public let name: String

    private enum CodingKeys: String, CodingKey {
        case name = "Label"
    }
}

struct CurrentAddressResponse: Decodable {
    let addresses: [CurrentAddress]

    private enum CodingKeys: String, CodingKey {
        case response = "Response"
        case view = "View"
        case result = "Result"
        case location = "Location"
        case address = "Address"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let response = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .response)
        var views = try response.nestedUnkeyedContainer(forKey: .view)

        var addresses = [CurrentAddress]()
        while !views.isAtEnd {
            let view = try views.nestedContainer(keyedBy: CodingKeys.self)
            var results = try view.nestedUnkeyedContainer(forKey: .result)
            while !results.isAtEnd {
                let result = try results.nestedContainer(keyedBy: CodingKeys.self)
                let location = try result.nestedContainer(keyedBy: CodingKeys.self, forKey: .location)
                let address = try location.decode(CurrentAddress.self, forKey: .address)
                addresses.append(address)
            }
        }

        self.addresses = addresses
    }
}
