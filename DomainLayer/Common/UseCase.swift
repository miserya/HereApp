//
//  UseCase.swift
//  DomainLayer
//
//  Created by Maria Holubieva on 08.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Combine

open class UseCase<Input, Output> {

    public init() {
    }

    func build(with args: Input) -> AnyPublisher<Output, Error> {
        preconditionFailure("Must be overridden!")
    }

    public func execute(with args: Input) -> AnyPublisher<Output, Error> {
        build(with: args)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
