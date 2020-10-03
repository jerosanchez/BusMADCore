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
                completion(RemoteNearestStopsLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    // MARK: - Helpers
    
    static private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let nearestStops = try NearestStopsMapper.map(data, with: response)
            return .success(nearestStops.toModels())
        } catch {
            return .failure(error)
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

private extension Array where Element == RemoteNearestStop {
    func toModels() -> [NearestStop] {
        map { stop in
            let latitude = stop.geometry.coordinates.count > 1 ? stop.geometry.coordinates[1] : 0
            let longitude = stop.geometry.coordinates.count > 0 ? stop.geometry.coordinates[0] : 0

            return NearestStop(
                id: stop.stopId,
                latitude: latitude,
                longitude: longitude,
                name: stop.stopName,
                address: stop.address,
                distanceInMeters: stop.metersToPoint,
                lines: stop.lines.toModels())}
    }
}

private extension Array where Element == RemoteNearestStopLine {
    func toModels() -> [NearestStopLine] {
        map { NearestStopLine(id: $0.line, origin: $0.nameA, destination: $0.nameB) }
    }
}
