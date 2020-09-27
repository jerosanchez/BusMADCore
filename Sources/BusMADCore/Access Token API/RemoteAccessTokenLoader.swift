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
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
        }
    }
}
