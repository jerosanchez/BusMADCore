//
//  Created by Jero Sánchez on 23/09/2020.
//

import Foundation

public class RemoteAccessTokenLoader: AccessTokenLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case invalidCredentials
        case wrongRequest
    }
    
    public typealias Result = LoadAccessTokenResult
    
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
                completion(RemoteAccessTokenLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    // MARK: - Helpers
    
    static private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let token = try AccessTokenMapper.map(data, from: response)
            return .success(AccessToken(token: token.accessToken, expirationTime: token.expirationTime, dailyCallsLimit: token.dailyCallsLimit, todayCallsCount: token.todayCallsCount))
        } catch {
            return .failure(error)
        }
    }
}
