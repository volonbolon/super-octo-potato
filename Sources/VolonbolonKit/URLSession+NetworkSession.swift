//
//  File.swift
//  
//
//  Created by Ariel Rodriguez on 14/01/2021.
//

import Foundation
import Combine

extension URLSession: NetworkSession {
    func get(from url: URL) -> AnyPublisher<Data, URLError> {
        let apiQueue = DispatchQueue(label: "API",
                                     qos: .default,
                                     attributes: .concurrent)
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .receive(on: apiQueue)
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    func post(with request: URLRequest) -> AnyPublisher<Data, URLError> {
        let apiQueue = DispatchQueue(label: "API",
                                     qos: .default,
                                     attributes: .concurrent)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .receive(on: apiQueue)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
