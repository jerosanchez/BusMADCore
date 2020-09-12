//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

enum LoadStopsResult {
    case success([NearestStop])
    case failure(Error)
}

protocol StopsLoader {
    func load(latitude: Double, longitude: Double, radius: Int, completion: @escaping (LoadStopsResult) -> Void)
}
