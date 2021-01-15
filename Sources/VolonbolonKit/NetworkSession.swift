//
//  File.swift
//  
//
//  Created by Ariel Rodriguez on 14/01/2021.
//

import Foundation
import Combine

internal protocol NetworkSession {
    func get(from url: URL) -> AnyPublisher<Data, URLError>
    func post(with request: URLRequest) -> AnyPublisher<Data, URLError>
}
