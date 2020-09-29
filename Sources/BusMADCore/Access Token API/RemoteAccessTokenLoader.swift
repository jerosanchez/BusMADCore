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
    }
    
    public init(from url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(clientId: String, passKey: String, completion: @escaping (Error?) -> Void) {
        let headers = [
            "clientId": clientId,
            "passKey": passKey
        ]
        client.get(from: url, headers: headers) { result in
            switch result {
            case let .success(data, _):
                if let _ = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.invalidCredentials)
                } else {
                    completion(.invalidData)
                }
            case .failure:
                completion(.connectivity)
            }
        }
    }
}

private struct Root: Decodable {
    let code: String
    let description: String
}
