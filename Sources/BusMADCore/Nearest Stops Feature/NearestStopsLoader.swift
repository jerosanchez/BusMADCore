//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

public enum LoadNearestStopsResult {
    case success([NearestStop])
    case failure(Error)
}

public protocol NearestStopsLoader {
    func load(latitude: Double, longitude: Double, radius: Int, completion: @escaping (LoadNearestStopsResult) -> Void)
}
