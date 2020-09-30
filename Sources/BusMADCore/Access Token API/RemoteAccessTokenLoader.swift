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
                completion(AccessTokenMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
