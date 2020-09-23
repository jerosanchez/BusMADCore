//
//  Created by Jero Sánchez on 23/09/2020.
//

import XCTest
import BusMADCore

class LoadAccessTokenFromRemoteUseCase: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)

        sut.load(clientId: anyClientId(), passKey: anyPassKey()) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let (sut, client) = makeSUT()

        sut.load(clientId: anyClientId(), passKey: anyPassKey()) { _ in }
        sut.load(clientId: anyClientId(), passKey: anyPassKey()) { _ in }

        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    func test_load_requestsDataUsingCorrectHeaders() {
        let clientId = anyClientId()
        let passKey = anyPassKey()
        let (sut, client) = makeSUT()

        sut.load(clientId: clientId, passKey: passKey) { _ in }

        XCTAssertEqual(client.headers.first!, ["clientId": clientId, "passKey": passKey])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteAccessTokenLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteAccessTokenLoader(from: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)

        return (sut, client)
    }
    
    private func anyClientId() -> String {
        return "a client Id"
    }
    
    private func anyPassKey() -> String {
        return "a pass key"
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
        ("test_load_requestsDataFromURL", test_load_requestsDataFromURL),
        ("test_loadTwice_requestsDataFromURLTwice", test_loadTwice_requestsDataFromURLTwice),
    ]
}
