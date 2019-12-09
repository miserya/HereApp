//
//  DomainLayerError.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

public enum DomainLayerError: Error {
    case emptyResponse
    case invalidRequest
}

extension DomainLayerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "Empty response"
        case .invalidRequest:
            return "Invalid request configuration"
        }
    }
}
