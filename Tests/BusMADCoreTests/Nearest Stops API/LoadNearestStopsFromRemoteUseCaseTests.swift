//
//  Created by Jero Sánchez on 12/09/2020.
//

import XCTest

class HTTPClient {
    var requestedURLs = [URL]()
    private var completions = [(Error) -> Void]()
    
    func get(from url: URL, completion: @escaping (Error) -> Void) {
        completions.append(completion)
        requestedURLs.append(url)
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        completions[index](error)
    }
}

class RemoteStopsLoader {
    let url: URL
    let client: HTTPClient
    
    enum Error {
        case connectivity
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { _ in
            completion(.connectivity)
        }
    }
}

class LoadNearestStopsFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load() { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load() { _ in }
        sut.load() { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnHTTPError() {
        let anyError = NSError(domain: "any error", code: 0)
        let (sut, client) = makeSUT()

        let exp = expectation(description: "Wait for load completion")
        
        sut.load() { receivedError in
            XCTAssertEqual(receivedError, .connectivity)
            exp.fulfill()
        }
        
        client.complete(withError: anyError)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteStopsLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteStopsLoader(url: url, client: client)
        return (sut, client)
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
        ("test_load_requestsDataFromURL", test_load_requestsDataFromURL),
    ]
}
