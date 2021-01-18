//
//  File.swift
//  
//
//  Created by Ariel Rodriguez on 18/01/2021.
//

import Foundation

extension VolonbolonKit {
    public struct FileIOHelper {
        private static let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        
        static private func fileURL(name: String) -> URL {
            URL(fileURLWithPath: FileIOHelper.libraryPath).appendingPathComponent("\(name).json")
        }
        
        
        /// Tries to load a persisted value from a JSON file.
        /// - Parameter name: propopsed name for the file
        /// - Throws: Error in case Decoding fails
        /// - Returns: Codable type fully hydrated
        static public func loadValue<T: Codable>(named name: String) throws -> T {
            let fileURL = FileIOHelper.fileURL(name: name)
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(T.self, from: data)
        }
        
        
        /// Persist an object on disk as a JSON file.
        /// - Parameters:
        ///   - value: Codable type to encode
        ///   - name: propopsed name for the file
        /// - Throws: Error in case Encoding operation fails
        static public func save<T: Codable>(value: T, named name: String) throws {
            let data = try JSONEncoder().encode(value)
            let fileURL = FileIOHelper.fileURL(name: name)
            try data.write(to: fileURL)
        }
    }
}
