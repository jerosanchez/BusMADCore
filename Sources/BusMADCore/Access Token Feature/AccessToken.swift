//
//  Created by Jero Sánchez on 23/09/2020.
//

import Foundation

public struct AccessToken: Equatable {
    public let token: UUID
    public let expirationTime: TimeInterval
    public let dailyCallsLimit: Int
    public let todayCallsCount: Int
    
    public init(token: UUID, expirationTime: TimeInterval, dailyCallsLimit: Int, todayCallsCount: Int) {
        self.token = token
        self.expirationTime = expirationTime
        self.dailyCallsLimit = dailyCallsLimit
        self.todayCallsCount = todayCallsCount
    }
}
