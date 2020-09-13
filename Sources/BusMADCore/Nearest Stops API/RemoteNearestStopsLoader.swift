//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

public class RemoteNearestStopsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error {
        case connectivity
        case invalidData
        case expiredSession
        case invalidRequest
    }
    
    public enum Result {
        case success([NearestStop])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(latitude: Double, longitude: Double, radius: Int, completion: @escaping (Result) -> Void) {
        let url = self.url
            .appendingPathComponent("/\(longitude)", isDirectory: true)
            .appendingPathComponent("\(latitude)", isDirectory: true)
            .appendingPathComponent("\(radius)", isDirectory: true)

        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .success(data, response):
                completion(NearestStopsMapper.map(data, with: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
