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
    
    func test_load_deliversErrorOnHTTPError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteAccessTokenLoader.Error.connectivity), when: {
            let clientError = NSError(domain: "a client error", code: 1)
            client.complete(withError: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(RemoteAccessTokenLoader.Error.invalidData), when: {
                let anyData = "any data".data(using: .utf8)!
                client.complete(withStatusCode: code, data: anyData, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteAccessTokenLoader.Error.invalidData), when: {
            let invalidJSON = "invalid JSON".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidCredentialsJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteAccessTokenLoader.Error.invalidCredentials), when: {
            client.complete(withStatusCode: 200, data: makeInvalidCredentialsJSON())
        })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithWrongRequestJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteAccessTokenLoader.Error.wrongRequest), when: {
            client.complete(withStatusCode: 200, data: makeWrongRequestJSON())
        })
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithUnknownCodeInJSON() {
        let (sut, client) = makeSUT()

        let samples = ["01", "79", "81", "89", "91"]
        
        samples.enumerated().forEach { (index, value) in
            expect(sut, toCompleteWith: .failure(RemoteAccessTokenLoader.Error.invalidData), when: {
                client.complete(withStatusCode: 200, data: makeJSONWithCode(value), at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithCode00AndEmptyDataInJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(RemoteAccessTokenLoader.Error.invalidData), when: {
            client.complete(withStatusCode: 200, data: makeJSONWithCode("00"))
        })
    }
    
    func test_load_deliversAccessTokenOn200HTTPResponseWithAccessTokenJSON() {
        let (sut, client) = makeSUT()
        let token = makeAccessToken()

        expect(sut, toCompleteWith: .success(token.model), when: {
            client.complete(withStatusCode: 200, data: makeJSONData(token.json))
        })
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
    
    private func makeInvalidCredentialsJSON() -> Data {
        let json: [String: Any] = [
            "code": "80",
            "description": "a description",
        ]
        
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    private func makeWrongRequestJSON() -> Data {
        let json: [String: Any] = [
            "code": "90",
            "description": "a description",
        ]
        
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    private func makeJSONWithCode(_ code: String) -> Data {
        let json: [String: Any] = [
            "code": "\(code)",
            "description": "a description",
        ]
        
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    private func makeAccessToken() -> (model: AccessToken, json: [String: Any]) {
        let token = AccessToken(
            token: UUID(),
            expirationTime: TimeInterval(floatLiteral: 1.0),
            dailyCallsLimit: 1,
            todayCallsCount: 0)
        
        let json: [String: Any] = [
            "code": "01",
            "description": "a description",
            "data": [
                [
                    "accessToken": "\(token.token.description)",
                    "tokenDteExpiration": [
                        "$date": token.expirationTime,
                    ],
                    "apiCounter": [
                        "current": token.todayCallsCount,
                        "dailyUse": token.dailyCallsLimit,
                    ],
                ],
            ]
        ]
        
        return (token, json)
    }
    
    private func makeJSONData(_ json: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    private func expect(_ sut: RemoteAccessTokenLoader, toCompleteWith expectedResult: RemoteAccessTokenLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load(clientId: anyClientId(), passKey: anyPassKey()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedToken), .success(expectedToken)):
                XCTAssertEqual(receivedToken, expectedToken, file: file, line: line)
            case let (.failure(receivedError as RemoteAccessTokenLoader.Error), .failure(expectedError as RemoteAccessTokenLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), received \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()

        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
        ("test_load_requestsDataFromURL", test_load_requestsDataFromURL),
        ("test_loadTwice_requestsDataFromURLTwice", test_loadTwice_requestsDataFromURLTwice),
        ("test_load_requestsDataUsingCorrectHeaders", test_load_requestsDataUsingCorrectHeaders),
        ("test_load_deliversErrorOnHTTPError", test_load_deliversErrorOnHTTPError),
        ("test_load_deliversErrorOnNon200HTTPResponse", test_load_deliversErrorOnNon200HTTPResponse),
        ("test_load_deliversErrorOn200HTTPResponseWithInvalidJSON", test_load_deliversErrorOn200HTTPResponseWithInvalidJSON),
        ("test_load_deliversErrorOn200HTTPResponseWithInvalidCredentialsJSON", test_load_deliversErrorOn200HTTPResponseWithInvalidCredentialsJSON),
        ("test_load_deliversErrorOn200HTTPResponseWithWrongRequestJSON", test_load_deliversErrorOn200HTTPResponseWithWrongRequestJSON),
        ("test_load_deliversErrorOn200HTTPResponseWithUnknownCodeInJSON", test_load_deliversErrorOn200HTTPResponseWithUnknownCodeInJSON),
        ("test_load_deliversErrorOn200HTTPResponseWithCode00AndEmptyDataInJSON", test_load_deliversErrorOn200HTTPResponseWithCode00AndEmptyDataInJSON),
        ("test_load_deliversAccessTokenOn200HTTPResponseWithAccessTokenJSON", test_load_deliversAccessTokenOn200HTTPResponseWithAccessTokenJSON),
    ]
}
