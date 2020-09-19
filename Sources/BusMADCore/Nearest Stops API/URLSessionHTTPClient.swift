//
//  Created by Jero Sánchez on 19/09/2020.
//

import Foundation

open class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public struct UnexpectedValuesRepresentation: Error { }
    
    open func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        get(from: url, headers: [:], completion: completion)
    }
    
    public func get(from url: URL, headers: [String: String], completion: @escaping (HTTPClientResult) -> Void) {
        var request = URLRequest(url: url)
        
        headers.forEach() { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
