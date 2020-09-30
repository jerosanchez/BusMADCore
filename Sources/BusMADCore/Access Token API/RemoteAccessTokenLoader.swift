//
//  Created by Jero Sánchez on 23/09/2020.
//

import Foundation

public class RemoteAccessTokenLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case invalidCredentials
        case wrongRequest
    }
    
    public enum Result {
        case success(AccessToken)
        case failure(Error)
    }
    
    public init(from url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(clientId: String, passKey: String, completion: @escaping (Result) -> Void) {
        let headers = [
            "clientId": clientId,
            "passKey": passKey
        ]
        client.get(from: url, headers: headers) { result in
            switch result {
            case let .success(data, response):
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                    switch root.code {
                    case "00":
                        if let token = root.token {
                            completion(.success(token))
                        } else {
                            completion(.failure(.invalidData))
                        }
                    case "80": completion(.failure(.invalidCredentials))
                    case "90": completion(.failure(.wrongRequest))
                    default: completion(.failure(.invalidData))
                    }
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

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
