//
//  Created by Jero Sánchez on 07/10/2020.
//

import XCTest
import BusMADCore

class AccessTokenStore {
    var retrieveCallsCount: Int = 0
    
    func retrieve() {
        retrieveCallsCount += 1
    }
}

class LocalAccessTokenLoader: AccessTokenLoader {
    private let store: AccessTokenStore
    
    init(store: AccessTokenStore) {
        self.store = store
    }
    
    func load(clientId: String, passKey: String, completion: @escaping (LoadAccessTokenResult) -> Void) {
        
    }
}

class LoadAccessTokenFromCacheTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.retrieveCallsCount, 0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalAccessTokenLoader, store: AccessTokenStore) {
        let store = AccessTokenStore()
        let sut = LocalAccessTokenLoader(store: store)
        return (sut, store)
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotMessageStoreUponCreation", test_init_doesNotMessageStoreUponCreation),
    ]
}
