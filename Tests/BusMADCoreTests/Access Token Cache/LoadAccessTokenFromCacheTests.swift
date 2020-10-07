//
//  Created by Jero Sánchez on 07/10/2020.
//

import XCTest
import BusMADCore

enum RetrieveCachedAccessTokenResult {
    case failure(Error)
}

class AccessTokenStore {
    typealias RetrieveCompletion = (RetrieveCachedAccessTokenResult) -> Void
    
    private var retrieveCompletions = [RetrieveCompletion]()
    
    enum ReceivedMessage {
        case retrieve
    }
    
    private(set) var receivedMessages = [ReceivedMessage]()
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        retrieveCompletions.append(completion)
        receivedMessages.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
}

class LocalAccessTokenLoader: AccessTokenLoader {
    private let store: AccessTokenStore
    
    init(store: AccessTokenStore) {
        self.store = store
    }
    
    func load(clientId: String, passKey: String, completion: @escaping (LoadAccessTokenResult) -> Void) {
        store.retrieve() { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

class LoadAccessTokenFromCacheTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load(clientId: "a client", passKey: "a pass key") { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> (sut: LocalAccessTokenLoader, store: AccessTokenStore) {
        let store = AccessTokenStore()
        let sut = LocalAccessTokenLoader(store: store)
        return (sut, store)
    }
    
    private func expect(_ sut: LocalAccessTokenLoader, toCompleteWith expectedResult: LoadAccessTokenResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load(clientId: "a client", passKey: "a pass key") { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(expectedError, receivedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_init_doesNotMessageStoreUponCreation", test_init_doesNotMessageStoreUponCreation),
    ]
}
