//
//  Created by Jero Sánchez on 12/09/2020.
//

import XCTest
import BusMADCore

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

        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.complete(withError: anyError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: emptyJSON(), at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPRequestWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            let invalidJSON = "invalid JSON".data(using: .utf8)!
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoStopOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            client.complete(withStatusCode: 200, data: emptyJSON())
        })
    }
    
    func test_load_deliversStopsOn200HTTPResponseWithStopsJSON() {
        let (sut, client) = makeSUT()
        
        let stop1 = makeStop(id: 1)
        let stop2 = makeStop(id: 2)
        
        expect(sut, toCompleteWith: .success([stop1.model, stop2.model]), when: {
            let stopsJSON = ["data": [stop1.json, stop2.json]]
            client.complete(withStatusCode: 200, data: try! JSONSerialization.data(withJSONObject: stopsJSON, options: []))
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteStopsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStopsLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func makeStop(id: Int) -> (model: NearestStop, json: [String: Any]){
        let line1 = NearestStopLine(id: 1, origin: "line1 origin", destination: "line1 destination")
        let line2 = NearestStopLine(id: 2, origin: "line2 origin", destination: "line2 destionation")

        let stop = NearestStop(id: id, latitude: 1.0, longitude: 1.0, name: "a name", address: "an address", distanceInMeters: 1, lines: [line1, line2])
        
        let stopJSON: [String: Any] = [
            "stopId": stop.id,
            "geometry": [
                "coordinates": [
                    stop.latitude,
                    stop.longitude
                ]
            ],
            "stopName": stop.name,
            "address": stop.address,
            "metersToPoint": stop.distanceInMeters,
            "lines": [
                [
                    "line": stop.lines[0].id,
                    "nameA": stop.lines[0].origin,
                    "nameB": stop.lines[0].destination,
                ],
                [
                    "line": stop.lines[1].id,
                    "nameA": stop.lines[1].origin,
                    "nameB": stop.lines[1].destination,
                ],
            ],
        ]

        return (stop, stopJSON)
    }
        
    private func emptyJSON() -> Data {
        let emptyJSON = """
{
    "code": "a code",
    "description": "a description",
    "data": []
}
"""
        return emptyJSON.data(using: .utf8)!
    }
    
    private func expect(_ sut: RemoteStopsLoader, toCompleteWith expectedResult: RemoteStopsLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load() { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedStops), .success(expectedStops)):
                XCTAssertEqual(receivedStops, expectedStops, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
    
    class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
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

    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
        ("test_load_requestsDataFromURL", test_load_requestsDataFromURL),
    ]
}
