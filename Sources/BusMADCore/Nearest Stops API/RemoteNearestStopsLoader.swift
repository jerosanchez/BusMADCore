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
        client.get(from: url.withQueryPathComponents(latitude, longitude, radius)) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(NearestStopsMapper.map(data, with: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private extension URL {
    func withQueryPathComponents(_ latitude: Double, _ longitude: Double, _ radius: Int) -> URL {
        return self
            .appendingPathComponent("/\(longitude)", isDirectory: true)
            .appendingPathComponent("\(latitude)", isDirectory: true)
            .appendingPathComponent("\(radius)", isDirectory: true)
    }
}
