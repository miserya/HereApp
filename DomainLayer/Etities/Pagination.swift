//
//  Pagination.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

public struct Pagination<Item: Decodable>: Decodable {
    public let nextPage: URL?
    public let prevPage: URL?
    public let items: [Item]

    private enum CodingKeys: String, CodingKey {
        case results
        case nextPage = "next"
        case prevPage = "previous"
        case items
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
            .nestedContainer(keyedBy: CodingKeys.self, forKey: .results)

        if let nextPageString = try? container.decode(String.self, forKey: .nextPage) {
            nextPage = URL(string: nextPageString)
        } else {
            nextPage = nil
        }
        if let prevPageString = try? container.decode(String.self, forKey: .prevPage) {
            prevPage = URL(string: prevPageString)
        } else {
            prevPage = nil
        }
        items = try container.decode([Item].self, forKey: .items)
    }
}
