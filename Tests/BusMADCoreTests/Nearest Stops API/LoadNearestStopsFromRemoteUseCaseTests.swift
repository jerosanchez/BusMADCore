//
//  Created by Jero Sánchez on 12/09/2020.
//

import XCTest

class HTTPClient {
    private var messages = [(url: URL, completion: (Result) -> Void)]()
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    enum Result {
        case success(Data, HTTPURLResponse)
        case failure(Error)
    }
    
    func get(from url: URL, completion: @escaping (Result) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data, response))
    }
}

class RemoteStopsLoader {
    let url: URL
    let client: HTTPClient
    
    enum Error {
        case connectivity
        case invalidData
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
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

        expect(sut, toCompleteWithError: .connectivity, when: {
            client.complete(withError: anyError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData, when: {
                let anyData = "any data".data(using: .utf8)!
                client.complete(withStatusCode: code, data: anyData, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPRequestWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithError: .invalidData, when: {
            let invalidJSON = "invalid JSON".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteStopsLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteStopsLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteStopsLoader, toCompleteWithError expectedError: RemoteStopsLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load() { receivedError in
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
        ("test_load_requestsDataFromURL", test_load_requestsDataFromURL),
    ]
}
