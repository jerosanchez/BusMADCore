//
//  Created by Jero Sánchez on 03/10/2020.
//

import Foundation

internal struct RemoteAccessToken: Decodable {
    internal let accessToken: UUID
    internal let expirationTime: TimeInterval
    internal let dailyCallsLimit: Int
    internal let todayCallsCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case accessToken
        case tokenDteExpiration
        case apiCounter
        
        enum TokenDteExpirationKeys: String, CodingKey {
            case expirationTime = "$date"
        }
        
        enum ApiCounterKeys: String, CodingKey {
            case dailyCallsLimit = "dailyUse"
            case todayCallsCount = "current"
        }
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(UUID.self, forKey: .accessToken)
        
        let tokenDteExpirationContainer = try container.nestedContainer(keyedBy: CodingKeys.TokenDteExpirationKeys.self, forKey: .tokenDteExpiration)
        self.expirationTime = try tokenDteExpirationContainer.decode(TimeInterval.self, forKey: .expirationTime)
        
        let apiCounterContainer = try container.nestedContainer(keyedBy: CodingKeys.ApiCounterKeys.self, forKey: .apiCounter)
        self.dailyCallsLimit = try apiCounterContainer.decode(Int.self, forKey: .dailyCallsLimit)
        self.todayCallsCount = try apiCounterContainer.decode(Int.self, forKey: .todayCallsCount)
    }
}
