//
//  Created by Jero Sánchez on 23/09/2020.
//

import Foundation

public class RemoteAccessTokenLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(from url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(clientId: String, passKey: String, completion: @escaping (LoadAccessTokenResult) -> Void) {
        let headers = [
            "clientId": clientId,
            "passKey": passKey]
        client.get(from: url, headers: headers) { _ in }
    }
}
