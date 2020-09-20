//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

internal struct RemoteNearestStop: Decodable {
    internal let stopId: Int
    internal let geometry: RemoteGeometry
    internal let stopName: String
    internal let address: String
    internal let metersToPoint: Int
    internal let lines: [RemoteNearestStopLine]
    
    internal var model: NearestStop {
        return NearestStop(
            id: stopId,
            latitude: geometry.coordinates[1],
            longitude: geometry.coordinates[0],
            name: stopName,
            address: address,
            distanceInMeters: metersToPoint,
            lines: lines.map {
                NearestStopLine(id: $0.line, origin: $0.nameA, destination: $0.nameB) }
        )
    }
}

internal struct RemoteGeometry: Decodable {
    internal let coordinates: [Double]
}

internal struct RemoteNearestStopLine: Decodable {
    internal let line: String
    internal let nameA: String
    internal let nameB: String
}
