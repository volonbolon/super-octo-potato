//
//  File.swift
//  
//
//  Created by Ariel Rodriguez on 14/01/2021.
//

import Foundation
import Combine

public protocol APIManager {
    func loadData(from url: URL) -> AnyPublisher<Data, VolonbolonKit.Networking.Error>
    func sendData<T: Codable>(to url: URL, body: T) -> AnyPublisher<Data, URLError>
}

extension VolonbolonKit { // Network
    public class Networking {
        /// Responsible for handling all networking calls.
        /// Warning: Must be created before using any public APIs
        
        public enum Error: LocalizedError {
            case urlError(URLError)
            case invalidResponse
            
            public var errorDescription: String? {
                switch self {
                case .urlError(let urlError):
                    return urlError.localizedDescription
                case .invalidResponse:
                    return "Invalid Response"
                }
            }
        }
        
        public class Manager: APIManager {
            let session: NetworkSession!
            init(session: NetworkSession) {
                self.session = session
            }
            
            convenience public init() {
                self.init(session: URLSession.shared)
            }
            
            /// Retrieves data from the specied location
            /// - Parameters:
            ///   - url: Location of the  resource to retrieve
            ///   - completionHandler: Either data or an error
            public func loadData(from url: URL) -> AnyPublisher<Data, VolonbolonKit.Networking.Error> {
                return session.get(from: url)
                    .mapError { (error) -> VolonbolonKit.Networking.Error in
                        return .urlError(error)
                    }
                    .eraseToAnyPublisher()
            }

            /// Send data to the specified resource
            /// - Parameters:
            ///   - url: Location to which we want to send data to
            ///   - body: codable object that will be send as http body
            ///   - completionHandler: returns the server response, or an error
            public func sendData<T: Codable>(to url: URL, body: T) -> AnyPublisher<Data, URLError> {
                var request = URLRequest(url: url)
                do {
                    let httpBody = try JSONEncoder().encode(body)
                    request.httpBody = httpBody
                    request.httpMethod = "POST"
                    return session.post(with: request)
                } catch {
                    return Empty<Data, URLError>()
                        .eraseToAnyPublisher()
                }
            }
        }
    }
}
