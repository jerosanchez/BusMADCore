//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

public class RemoteNearestStopsLoader: NearestStopsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case expiredSession
        case invalidRequest
    }
    
    public typealias Result = LoadNearestStopsResult
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(latitude: Double, longitude: Double, radius: Int, completion: @escaping (Result) -> Void) {
        let url = urlWithQueryPathComponents(latitude, longitude, radius)
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(NearestStopsMapper.map(data, with: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func urlWithQueryPathComponents(_ latitude: Double, _ longitude: Double, _ radius: Int) -> URL {
        return url
            .appendingPathComponent("/\(longitude)", isDirectory: true)
            .appendingPathComponent("\(latitude)", isDirectory: true)
            .appendingPathComponent("\(radius)", isDirectory: true)
    }
}
