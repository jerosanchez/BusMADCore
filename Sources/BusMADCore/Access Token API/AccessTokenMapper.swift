//
//  Created by Jero Sánchez on 30/09/2020.
//

import Foundation

internal final class AccessTokenMapper {
    private struct Root: Decodable {
        internal let code: String
        internal let description: String
        internal let data: [RemoteAccessToken]?
    }
    
    private static var OK_200: Int { return 200 }
    
    static internal func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteAccessToken {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteAccessTokenLoader.Error.invalidData
        }
        
        switch root.code {
        case "00":
            if let accessToken = root.data?.first {
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
