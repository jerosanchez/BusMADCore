//
//  Created by Jero Sánchez on 03/10/2020.
//

import XCTest
import BusMADCore

class AccessTokenAPIEndToEndTests: XCTestCase {
    
    func test_EndToEndGETAccessTokenResult_receivesAValidAccessToken() {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let serviceURL = URL(string: "https://openapi.emtmadrid.es/v2/mobilitylabs/user/login/")!
        let loader = RemoteAccessTokenLoader(from: serviceURL, client: client)

        let exp = expectation(description: "Wait for load completion")
        
        var receivedToken: AccessToken?
        loader.load(clientId: CLIENT_ID, passKey: PASS_KEY) { result in
            switch result {
            case let .success(accessToken):
                receivedToken = accessToken
            case let .failure(error):
                XCTFail("Expected an access token, got error \(error) instead.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        XCTAssertNotNil(receivedToken)
    }
}
