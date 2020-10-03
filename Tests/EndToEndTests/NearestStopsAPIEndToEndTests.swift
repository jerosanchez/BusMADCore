//
//  Created by Jero Sánchez on 19/09/2020.
//

import XCTest
import BusMADCore

class NearestStopsAPIEndToEndTests: XCTestCase {
    
    func test_endToEndGETNearestStopsResult_matchesExpectedData() {
        switch getNearestStopsResult() {
        case let .success(stops)?:
            XCTAssertEqual(stops.count, 3, "Expected 3 stops in the result")
            
        case let .failure(error)?:
            XCTFail("Expected successfull load result, got \(error) instead.")
            
        default:
            XCTFail("Expected successfull load result, got no result instead.")
        }
    }
    
    // MARK: - Helpers
    
    private func getNearestStopsResult(file: StaticString = #file, line: UInt = #line) -> LoadNearestStopsResult? {

        let latitude = 40.417008
        let longitude = -3.705487
        let radius = 350
        let serviceURL = URL(string: APIConfig.getNearestStopsEndpoint)!
        let client = makeSigningClient()
        let loader = RemoteNearestStopsLoader(url: serviceURL, client: client)
        
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadNearestStopsResult?
        loader.load(latitude: latitude, longitude: longitude, radius: radius) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    private func makeSigningClient() -> SigningURLSessionHTTPClient {
        let getAccessTokenURL = URL(string: APIConfig.getAccessTokenEndpoint)!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let accessTokenLoader = RemoteAccessTokenLoader(from: getAccessTokenURL, client: client)
        return SigningURLSessionHTTPClient(client: client, accessTokenLoader: accessTokenLoader)
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_endToEndGETNearestStopsResult_matchesExpectedData", test_endToEndGETNearestStopsResult_matchesExpectedData),
    ]
}

private class SigningURLSessionHTTPClient: HTTPClient {
    private let client: URLSessionHTTPClient
    private let accessTokenLoader: AccessTokenLoader
    
    typealias HTTPRequestHeaders = [String: String]
    
    init(client: URLSessionHTTPClient, accessTokenLoader: AccessTokenLoader) {
        self.client = client
        self.accessTokenLoader = accessTokenLoader
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        get(from: url, headers: [:], completion: completion)
    }
    
    func get(from url: URL, headers: [String: String], completion: @escaping (HTTPClientResult) -> Void) {
        sign(headers) { signedHeaders in
            if let headers = signedHeaders {
                self.client.get(from: url, headers: headers, completion: completion)
            } else {
                completion(.failure(NSError(domain: "End-to-end tests", code: 1, userInfo: ["description": "Unable to load access token from the remote service"])))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func sign(_ headers: HTTPRequestHeaders, completion: @escaping (HTTPRequestHeaders?) -> Void) {
        accessTokenLoader.load(clientId: CLIENT_ID, passKey: PASS_KEY) { result in
            switch result {
            case let .success(accessToken):
                var headers = headers
                headers["accessToken"] = accessToken.token.description.lowercased()
                completion(headers)
            case .failure:
                completion(nil)
            }
        }
    }
}
