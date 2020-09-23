//
//  Created by Jero Sánchez on 23/09/2020.
//

import Foundation

public struct AccessToken {
    public let token: UUID
    public let expirationTime: Date
    public let dailyCallsLimit: Int
    public let todayCallsCount: Int
}
