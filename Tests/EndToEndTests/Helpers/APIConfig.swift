//
//  Created by Jero Sánchez on 03/10/2020.
//

import Foundation

internal struct APIConfig {
    
    static private var baseURL: String {
        return "https://openapi.emtmadrid.es/v2/"
    }
    
    static internal var getAccessTokenEndpoint: String { return baseURL + "mobilitylabs/user/login/" }
    static internal var getNearestStopsEndpoint: String { return baseURL + "transport/busemtmad/stops/arroundxy" }
}
