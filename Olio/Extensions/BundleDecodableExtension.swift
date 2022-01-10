//
//  BundleDecodableExtension.swift
//  Olio
//
//  Created by Jake King on 10/01/2022.
//

import Foundation

// Bundle is responsible for working with all our main app's code and resources.
extension Bundle {
    /// Loads decodable JSON data from the app bundle.
    /// - Parameters:
    ///   - type: The type of decodable data being decoded.
    ///   - from: The name of the file containing the JSON data to be decoded.
    ///   - dateDecodingStrategy: A date decoding strategy enabling the handling of dates in whichever way makes
    ///   sense for the data in the file.
    ///   - keyDecodingStrategy: A key decoding strategy enabling the conversion between name case conventions.
    /// - Returns: Returns loaded data.
    func decode<T: Decodable>( // generic type parameter conforming to decodable since data type being used is unknown
        _ type: T.Type, // some type of data that conforms to the decodable protocol
        from file: String,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
            // Locate the requested file inside the current bundle.
            guard let url = self.url(forResource: file, withExtension: nil) else {
                fatalError("Failed to locate \(file) in bundle.")
            }

            // Load the contents of the file into a Data instance.
            guard let data = try? Data(contentsOf: url) else {
                fatalError("Failed to load \(file) from bundle.")
            }

            // Configure a JSONDecoder instance with settings passed in.
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy

            // Decode the data into whichever type was requested.
            do {
                return try decoder.decode(T.self, from: data)
            } catch DecodingError.keyNotFound(let key, let context) {
                // swiftlint:disable:next line_length
                fatalError("Failed to decode \(file) from bundle due to missing key \(key.stringValue) not found - \(context.debugDescription)")
            } catch DecodingError.typeMismatch(_, let context) {
                fatalError("Failed to decode \(file) from bundle due to type mismatch - \(context.debugDescription)")
            } catch DecodingError.valueNotFound(let type, let context) {
                // swiftlint:disable:next line_length
                fatalError("Failed to decode \(file) from bundle due to missing \(type) value - \(context.debugDescription)")
            } catch DecodingError.dataCorrupted(_) {
                fatalError("Failed to decode \(file) from bundle due to invalid JSON.")
            } catch {
                fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
            }
        }
}
