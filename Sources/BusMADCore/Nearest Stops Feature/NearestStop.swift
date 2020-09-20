//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

public struct NearestStop: Equatable {
    public let id: Int
    public let latitude: Double
    public let longitude: Double
    public let name: String
    public let address: String
    public let distanceInMeters: Int
    public let lines: [NearestStopLine]
    
    public init(id: Int, latitude: Double, longitude: Double, name: String, address: String, distanceInMeters: Int, lines: [NearestStopLine]) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.address = address
        self.distanceInMeters = distanceInMeters
        self.lines = lines
    }
}

public struct NearestStopLine: Equatable {
    public let id: String
    public let origin: String
    public let destination: String
    
    public init(id: String, origin: String, destination: String) {
        self.id = id
        self.origin = origin
        self.destination = destination
    }
}
