//
//  Created by Jero Sánchez on 23/09/2020.
//

import Foundation

struct AccessToken {
    let token: UUID
    let expirationTime: Date
    let dailyCallsLimit: Int
    let todayCallsCount: Int
}
