//
//  Created by Jero Sánchez on 03/10/2020.
//

import XCTest
import BusMADCore

class AccessTokenAPIEndToEndTests: XCTestCase {
    
    func test_EndToEndGETAccessTokenResult_receivesAValidAccessToken() {
        switch getAccessTokenResult() {
        case .success:
            break
        case let .failure(error):
            XCTFail("Expected successfull load result, got \(error) instead.")
        default:
            XCTFail("Expected successfull result, got no result instead.")
        }
    }
    
    // MARK: Helpers
    
    private func getAccessTokenResult(file: StaticString = #file, line: UInt = #line) -> LoadAccessTokenResult? {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let serviceURL = URL(string: APIConfig.getAccessTokenEndpoint)!
        let loader = RemoteAccessTokenLoader(from: serviceURL, client: client)

        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadAccessTokenResult?
        loader.load(clientId: CLIENT_ID, passKey: PASS_KEY) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return receivedResult
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_EndToEndGETAccessTokenResult_receivesAValidAccessToken", test_EndToEndGETAccessTokenResult_receivesAValidAccessToken),
    ]
}
