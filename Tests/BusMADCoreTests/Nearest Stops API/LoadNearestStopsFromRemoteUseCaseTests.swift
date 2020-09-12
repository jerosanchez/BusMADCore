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
        
        let line1 = NearestStopLine(id: 1, origin: "line1 origin", destination: "line1 destination")
        let line2 = NearestStopLine(id: 2, origin: "line2 origin", destination: "line2 destionation")

        let stop1 = NearestStop(id: 1, latitude: 1.0, longitude: 1.0, name: "stop1", address: "stop1 address", distanceInMeters: 1, lines: [line1, line2])
        
        let stopJSON1: [String: Any] = [
            "stopId": stop1.id,
            "geometry": [
                "coordinates": [
                    stop1.latitude, stop1.longitude
                ]
            ],
            "stopName": stop1.name,
            "address": stop1.address,
            "metersToPoint": stop1.distanceInMeters,
            "lines": [
                [
                    "line": stop1.lines[0].id,
                    "nameA": stop1.lines[0].origin,
                    "nameB": stop1.lines[0].destination,
                ],
                [
                    "line": stop1.lines[1].id,
                    "nameA": stop1.lines[1].origin,
                    "nameB": stop1.lines[1].destination,
                ],
            ],
        ]
        
        let line3 = NearestStopLine(id: 1, origin: "line3 origin", destination: "line3 destination")
        let line4 = NearestStopLine(id: 2, origin: "line4 origin", destination: "line4 destination")

        let stop2 = NearestStop(id: 2, latitude: 2.0, longitude: 2.0, name: "stop2", address: "stop2 address", distanceInMeters: 1, lines: [line3, line4])
        
        let stopJSON2: [String: Any] = [
            "stopId": stop2.id,
            "geometry": [
                "coordinates": [
                    stop2.latitude, stop2.longitude
                ]
            ],
            "stopName": stop2.name,
            "address": stop2.address,
            "metersToPoint": stop2.distanceInMeters,
            "lines": [
                [
                    "line": stop2.lines[0].id,
                    "nameA": stop2.lines[0].origin,
                    "nameB": stop2.lines[0].destination,
                ],
                [
                    "line": stop2.lines[1].id,
                    "nameA": stop2.lines[1].origin,
                    "nameB": stop2.lines[1].destination,
                ],
            ],
        ]
        
        let stopsJSON = ["data": [stopJSON1, stopJSON2]]
        let stops = [stop1, stop2]

        expect(sut, toCompleteWith: .success(stops), when: {
            client.complete(withStatusCode: 200, data: try! JSONSerialization.data(withJSONObject: stopsJSON, options: []))
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteStopsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteStopsLoader(url: url, client: client)
        return (sut, client)
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
