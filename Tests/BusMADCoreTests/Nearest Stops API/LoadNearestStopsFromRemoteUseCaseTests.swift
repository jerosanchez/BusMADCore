//
//  Created by Jero Sánchez on 12/09/2020.
//

import XCTest

class HTTPClient {
    var requestedURLs = [URL]()
}

class RemoteStopsLoader {
    
}

class LoadNearestStopsFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
        let _ = RemoteStopsLoader()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    static var allTests = [
        ("test_init_doesNotRequestDataFromURL", test_init_doesNotRequestDataFromURL),
    ]
}
