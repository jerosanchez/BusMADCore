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
        let serviceURL = URL(string: "https://openapi.emtmadrid.es/v2/transport/busemtmad/stops/arroundxy")!
        let client = SignedURLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
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
}

private class SignedURLSessionHTTPClient: URLSessionHTTPClient {
    override func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let client = SignedURLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let serviceURL = URL(string: "https://openapi.emtmadrid.es/v2/mobilitylabs/user/login/")!
        let loader = RemoteAccessTokenLoader(from: serviceURL, client: client)
        
        loader.load(clientId: CLIENT_ID, passKey: PASS_KEY) { result in
            switch result {
            case let .success(accessToken):
                let headers = ["accessToken": accessToken.token.description]
                self.get(from: url, headers: headers, completion: completion)
            case .failure:
                completion(.failure(NSError(domain: "End-to-end tests", code: 1, userInfo: ["description": "Unable to load an access token from the service"])))
            }
        }
    }
}
