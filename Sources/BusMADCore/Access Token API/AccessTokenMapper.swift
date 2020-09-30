//
//  Created by Jero Sánchez on 30/09/2020.
//

import Foundation

internal final class AccessTokenMapper {
    
    private struct Root: Decodable {
        let code: String
        let description: String
        let data: TokenInfo?
        
        var token: AccessToken? {
            guard let data = data else { return nil }
            
            return AccessToken(
                token: data.accessToken,
                expirationTime: data.expirationTime,
                dailyCallsLimit: data.dailyCallsLimit,
                todayCallsCount: data.todayCallsCount)
        }
    }

    private struct TokenInfo: Decodable {
        let accessToken: UUID
        let expirationTime: TimeInterval
        let dailyCallsLimit: Int
        let todayCallsCount: Int
        
        enum CodingKeys: String, CodingKey {
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
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.accessToken = try container.decode(UUID.self, forKey: .accessToken)
            
            let tokenDteExpirationContainer = try container.nestedContainer(keyedBy: CodingKeys.TokenDteExpirationKeys.self, forKey: .tokenDteExpiration)
            self.expirationTime = try tokenDteExpirationContainer.decode(TimeInterval.self, forKey: .expirationTime)
            
            let apiCounterContainer = try container.nestedContainer(keyedBy: CodingKeys.ApiCounterKeys.self, forKey: .apiCounter)
            self.dailyCallsLimit = try apiCounterContainer.decode(Int.self, forKey: .dailyCallsLimit)
            self.todayCallsCount = try apiCounterContainer.decode(Int.self, forKey: .todayCallsCount)
        }
    }
    
    static internal func map(_ data: Data, from response: HTTPURLResponse) -> RemoteAccessTokenLoader.Result {
        guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteAccessTokenLoader.Error.invalidData)
        }
        
        switch root.code {
        case "00":
            if let token = root.token {
                return .success(token)
            } else {
                return .failure(RemoteAccessTokenLoader.Error.invalidData)
            }
        case "80": return .failure(RemoteAccessTokenLoader.Error.invalidCredentials)
        case "90": return .failure(RemoteAccessTokenLoader.Error.wrongRequest)
        default: return .failure(RemoteAccessTokenLoader.Error.invalidData)
        }
    }
}
