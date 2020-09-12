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
                completion(self.map(data, with: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func map(_ data: Data, with response: HTTPURLResponse) -> Result {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.data.map { $0.model })
        } else {
            return .failure(.invalidData)
        }
    }
}

internal struct Root: Decodable {
    internal let data: [RemoteStop]
}

internal struct RemoteStop: Decodable {
    internal let stopId: Int
    internal let geometry: RemoteGeometry
    internal let stopName: String
    internal let address: String
    internal let metersToPoint: Int
    internal let lines: [RemoteLine]
    
    var model: NearestStop {
        return NearestStop(
            id: stopId,
            latitude: geometry.coordinates[1],
            longitude: geometry.coordinates[0],
            name: stopName,
            address: address,
            distanceInMeters: metersToPoint,
            lines: lines.map { NearestStopLine(
                id: $0.line,
                origin: $0.nameA,
                destination: $0.nameB)})
    }
}

internal struct RemoteGeometry: Decodable {
    internal let coordinates: [Double]
}

internal struct RemoteLine: Decodable {
    internal let line: Int
    internal let nameA: String
    internal let nameB: String
}
