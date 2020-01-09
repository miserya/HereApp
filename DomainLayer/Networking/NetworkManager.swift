//
//  NetworkManager.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation
import Combine

class NetworkingManager: NSObject {

    static var `default`: NetworkingManager = NetworkingManager()

    private lazy var dataSession: URLSession = { return URLSession(configuration: .default) }()

    deinit {
        self.dataSession.invalidateAndCancel()
    }

    //MARK: - Data Request

    func request<Output: Decodable>(_ target: RequestTarget) -> AnyPublisher<Output, Error> {

        guard var urlComponents = URLComponents(string: "\(target.baseURL)\(target.route.path)") else {
            return Publishers.Fail(outputType: Output.self, failure: DomainLayerError.invalidRequest).eraseToAnyPublisher()
        }
        urlComponents.queryItems = target.params?.map({ (arg) -> URLQueryItem in
            return URLQueryItem(name: arg.key, value: String(describing: arg.value))
        })
        urlComponents.queryItems?.append(URLQueryItem(name: "app_id", value: ServerConfiguration.appID))
        urlComponents.queryItems?.append(URLQueryItem(name: "app_code", value: ServerConfiguration.appCode))

        guard let url = urlComponents.url else {
            return Publishers.Fail(outputType: Output.self, failure: DomainLayerError.invalidRequest).eraseToAnyPublisher()
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = target.route.method
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        debugPrint("REQUEST: \(urlRequest)")

        return dataSession.dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, response: URLResponse) -> Output in
                return try JSONDecoder().decode(Output.self, from: data) }
            .eraseToAnyPublisher()
    }
}
