//
//  UseCase.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation

open class UseCase<Input, Output> {

    public init() {
    }

    func build(with args: Input, completion: ((Result<Output, Error>) -> Void)?) {
        preconditionFailure("Must be overridden!")
    }

    public func execute(with args: Input, completion: ((Result<Output, Error>) -> Void)?) {
         DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.build(with: args, completion: { (result: Result<Output, Error>) in
                DispatchQueue.main.async {
                    completion?(result)
                }
            })
        }
    }
}
