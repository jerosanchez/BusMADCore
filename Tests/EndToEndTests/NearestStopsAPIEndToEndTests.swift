//
//  Created by Jero Sánchez on 19/09/2020.
//

import XCTest
import BusMADCore

class NearestStopsAPIEndToEndTests: XCTestCase {
    
    func test_endToEndGETNearestStopsResult_matchesExpectedData() {
        let latitude = 40.385558
        let longitude = -3.640491
        let radius = 200
        let serviceURL = URL(string: "https://openapi.emtmadrid.es/v2/transport/busemtmad/stops/arroundxy")!
        let client = URLSessionHTTPClientSigned()
        let loader = RemoteNearestStopsLoader(url: serviceURL, client: client)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadNearestStopsResult?
        loader.load(latitude: latitude, longitude: longitude, radius: radius) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        switch receivedResult {
        case let .success(stops)?:
            XCTAssertEqual(stops.count, 3)
        case let .failure(error)?:
            XCTFail("Expected successfull load result, got \(error) instead.")
        default:
            XCTFail("Expected successfull load result, got no result instead.")
        }
    }
}

private class URLSessionHTTPClientSigned: URLSessionHTTPClient {
    override func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        let headers = ["accessToken": ACCESS_TOKEN]
        get(from: url, headers: headers, completion: completion)
    }
}
