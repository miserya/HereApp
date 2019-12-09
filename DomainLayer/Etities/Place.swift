//
//  Place.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

public struct Place: Decodable {
    public let id: String
    public let title: String
    public let icon: URL

    public let latitude: Double
    public let longitude: Double
    public let distance: Double

    private enum CodingKeys: String, CodingKey {
        case id
        case position
        case distance
        case title
        case icon
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        icon = try container.decode(URL.self, forKey: .icon)

        let coordinates = try container.decode([Double].self, forKey: .position)
        if let latitude = coordinates.first, let longitude = coordinates.last {
            self.latitude = latitude
            self.longitude = longitude
        } else {
            throw DecodingError.dataCorruptedError(forKey: .position, in: container, debugDescription: "Invalid position responce for place.")
        }

        distance = try container.decode(Double.self, forKey: .distance)
    }
}
