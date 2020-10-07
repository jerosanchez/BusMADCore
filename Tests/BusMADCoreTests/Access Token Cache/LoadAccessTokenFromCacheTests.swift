//
//  Created by Jero Sánchez on 07/10/2020.
//

import XCTest
import BusMADCore

class AccessTokenStore {
    var completions = [(AccessToken) -> Void]()
    
    func retrieve(completion: @escaping (AccessToken) -> Void) {
        completions.append(completion)
    }
}

class LocalAccessTokenLoader: AccessTokenLoader {
    private let store: AccessTokenStore
    
    init(store: AccessTokenStore) {
        self.store = store
    }
    
    func load(clientId: String, passKey: String, completion: @escaping (LoadAccessTokenResult) -> Void) {
        store.retrieve() { _ in }
    }
}

class LoadAccessTokenFromCacheTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.completions.count, 0)
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load(clientId: "a client", passKey: "a pass key") { _ in }
        
        XCTAssertEqual(store.completions.count, 1)
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
