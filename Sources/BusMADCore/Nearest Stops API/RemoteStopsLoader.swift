//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteStopsLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error {
        case connectivity
        case invalidData
    }
    
    public enum Result {
        case success([NearestStop])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200, let _ = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success([]))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

internal struct Root: Decodable {
    internal let data: [RemoteNearestStop]
}

internal struct RemoteNearestStop: Decodable {
    internal let id: Int
    internal let latitude: Double
    internal let longitude: Double
    internal let name: String
    internal let address: String
    internal let distanceInMeters: Int
    internal let lines: [RemoteNearestStopLine]
}

internal struct RemoteNearestStopLine: Decodable {
    internal let id: Int
    internal let origin: String
    internal let destination: String
}
