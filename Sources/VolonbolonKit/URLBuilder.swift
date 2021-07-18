//
//  File.swift
//  
//
//  Created by Ariel Rodriguez on 17/07/2021.
//

import Foundation

public class URLBuilder {
    private var components: URLComponents
    
    public init() {
        self.components = URLComponents()
    }
    
    public func set(scheme: String) -> URLBuilder {
        self.components.scheme = scheme
        return self
    }
    
    public func set(host: String) -> URLBuilder {
        self.components.host = host
        return self
    }
    
    public func set(port: Int) -> URLBuilder {
        self.components.port = port
        return self
    }
    
    public func set(path: String) -> URLBuilder {
        var path = path
        if !path.hasPrefix("/") {
            path = "/" + path
        }
        self.components.path = path
        return self
    }
    
    public func addQueryItem(name: String, value: String) -> URLBuilder {
        if self.components.queryItems == nil {
            self.components.queryItems = []
        }
        let queryItem = URLQueryItem(name: name, value: value)
        self.components.queryItems?.append(queryItem)
        return self
    }
    
    public func build() -> URL? {
        return self.components.url
    }
}
