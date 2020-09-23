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
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let clientId = "clientId"
        let passKey = "pass key"
        let (sut, client) = makeSUT()

        sut.load(from: url, clientId: clientId, passKey: passKey) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let clientId = "clientId"
        let passKey = "pass key"
        let (sut, client) = makeSUT()

        sut.load(from: url, clientId: clientId, passKey: passKey) { _ in }
        sut.load(from: url, clientId: clientId, passKey: passKey) { _ in }

        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: RemoteAccessTokenLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteAccessTokenLoader(client: client)
        
        return (sut, client)
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
    ]
}
