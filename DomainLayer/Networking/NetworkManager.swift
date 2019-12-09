//
//  NetworkManager.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

class NetworkingManager: NSObject {

    static var `default`: NetworkingManager = NetworkingManager()

    private lazy var dataSession: URLSession = { return URLSession(configuration: .default) }()

    deinit {
        self.dataSession.invalidateAndCancel()
    }

    //MARK: - Data Request

    func request<Output: Decodable>(_ target: RequestTarget, completion: ((Result<Output, Error>) -> Void)?) {

        guard var urlComponents = URLComponents(string: "\(target.baseURL)\(target.route.path)") else {
            completion?(.failure(DomainLayerError.invalidRequest))
            return
        }
        urlComponents.queryItems = target.params?.map({ (arg) -> URLQueryItem in
            return URLQueryItem(name: arg.key, value: String(describing: arg.value))
        })
        urlComponents.queryItems?.append(URLQueryItem(name: "app_id", value: ServerConfiguration.appID))
        urlComponents.queryItems?.append(URLQueryItem(name: "app_code", value: ServerConfiguration.appCode))

        guard let url = urlComponents.url else {
            completion?(.failure(DomainLayerError.invalidRequest))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = target.route.method
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        debugPrint("REQUEST: \(urlRequest)")

        let dataTask = self.dataSession.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completion?(Result.failure(error))
            }
            else if let data = data {
                do {
                    let output = try JSONDecoder().decode(Output.self, from: data)
                    completion?(Result.success(output))
                }
                catch {
                    completion?(Result.failure(error))
                }
            }
        }
        dataTask.resume()
    }
}
