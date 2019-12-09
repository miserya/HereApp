//
//  PlaceCategory.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

public struct PlaceCategory: Decodable, Equatable {
    public let id: String
    public let title: String
    public let icon: URL

    public init(id: String, title: String, icon: URL) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

struct PlaceCategoriesResponse: Decodable {
    let items: [PlaceCategory]
}
