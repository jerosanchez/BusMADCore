//
//  Created by Jero Sánchez on 23/09/2020.
//

import XCTest
import BusMADCore

class RemoteAccessTokenLoader {
    private let url: URL
    private let client: HTTPClient
    
    init(from url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(clientId: String, passKey: String, completion: @escaping (LoadAccessTokenResult) -> Void) {
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
        let (sut, client) = makeSUT(url: url)

        sut.load(clientId: clientId, passKey: passKey) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let clientId = "clientId"
        let passKey = "pass key"
        let (sut, client) = makeSUT()

        sut.load(clientId: clientId, passKey: passKey) { _ in }
        sut.load(clientId: clientId, passKey: passKey) { _ in }

        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteAccessTokenLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteAccessTokenLoader(from: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)

        return (sut, client)
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
    ]
}
