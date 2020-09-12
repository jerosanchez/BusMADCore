//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

struct NearestStop {
    let id: Int
    let latitude: Double
    let longitude: Double
    let name: String
    let address: String
    let distanceInMeters: Int
    let lines: [NearestStopLine]
}

struct NearestStopLine {
    let id: Int
    let origin: String
    let destination: String
}
