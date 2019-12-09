//
//  RequestTarget.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

protocol RequestTarget {
    var baseURL: String { get }
    var route: Route { get }
    var params: [String: Any]? { get }
}

enum Route {
    case get(String)
    case post(String)
    case put(String)
    case delete(String)

    var path: String {
        switch self {
        case .get(let path):
            return path
        case .post(let path):
            return path
        case .put(let path):
            return path
        case .delete(let path):
            return path
        }
    }

    var method: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .delete:
            return "DELETE"
        }
    }
}
