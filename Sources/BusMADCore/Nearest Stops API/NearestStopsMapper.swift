//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

class NearestStopsMapper {
    struct Root: Decodable {
        internal let data: [RemoteNearestStop]
    }

    static func map(_ data: Data, with response: HTTPURLResponse) -> RemoteNearestStopsLoader.Result {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.data.map { $0.model })
        } else {
            return .failure(.invalidData)
        }
    }
}

internal struct RemoteNearestStop: Decodable {
    internal let stopId: Int
    internal let geometry: RemoteGeometry
    internal let stopName: String
    internal let address: String
    internal let metersToPoint: Int
    internal let lines: [RemoteNearestStopLine]
    
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

internal struct RemoteNearestStopLine: Decodable {
    internal let line: Int
    internal let nameA: String
    internal let nameB: String
}
