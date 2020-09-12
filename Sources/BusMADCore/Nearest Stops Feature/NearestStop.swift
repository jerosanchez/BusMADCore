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
}

public struct NearestStopLine: Equatable {
    public let id: Int
    public let origin: String
    public let destination: String
}
