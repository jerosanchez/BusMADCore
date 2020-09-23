//
//  Created by Jero Sánchez on 23/09/2020.
//

import XCTest
import BusMADCore

class RemoteAccessTokenLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(from url: URL, clientId: String, passKey: String, completion: @escaping (LoadAccessTokenResult) -> Void) {
        client.get(from: url) { _ in }
    }
}

class LoadAccessTokenFromRemoteUseCase: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        let _ = RemoteAccessTokenLoader(client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let clientId = "clientId"
        let passKey = "pass key"
        let client = HTTPClientSpy()
        let sut = RemoteAccessTokenLoader(client: client)
        
        sut.load(from: url, clientId: clientId, passKey: passKey) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
    ]
}
