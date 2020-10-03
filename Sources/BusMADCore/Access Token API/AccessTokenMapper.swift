//
//  Created by Jero Sánchez on 30/09/2020.
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
            case dailyCallsLimit = "current"
            case todayCallsCount = "dailyUse"
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

internal final class AccessTokenMapper {
    private struct Root: Decodable {
        internal let code: String
        internal let description: String
        internal let data: RemoteAccessToken?
    }
    
    private static var OK_200: Int { return 200 }
    
    static internal func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteAccessToken {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteAccessTokenLoader.Error.invalidData
        }
        
        switch root.code {
        case "00":
            if let accessToken = root.data {
                return accessToken
            } else {
                throw RemoteAccessTokenLoader.Error.invalidData
            }
        case "80": throw RemoteAccessTokenLoader.Error.invalidCredentials
        case "90": throw RemoteAccessTokenLoader.Error.wrongRequest
        default: throw RemoteAccessTokenLoader.Error.invalidData
        }
    }
}
