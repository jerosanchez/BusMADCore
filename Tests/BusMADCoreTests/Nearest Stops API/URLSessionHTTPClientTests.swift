//
//  Created by Jero Sánchez on 14/09/2020.
//

import XCTest
import BusMADCore

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_performsGETRequestWithURL() {
        URLProtocol.registerClass(URLProtocolStub.self)
        let url = URL(string: "https://a-url.com")!
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
            
            exp.fulfill()
        }
        
        sut.get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    func test_getFromURL_failsOnRequestError() {
        URLProtocol.registerClass(URLProtocolStub.self)
        let url = URL(string: "https://a-url.com")!
        let sut = URLSessionHTTPClient()
        let requestError = NSError(domain: "any error", code: 0, userInfo: nil)
        URLProtocolStub.stub(error: requestError)
        
        let exp = expectation(description: "Wait for request")
        
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, requestError)
            default:
                XCTFail("Expected \(requestError) error, got \(result) instead.")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    // MARK: Helpers
    
    class URLProtocolStub: URLProtocol {
        private static var error: Error?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        static func stub(error: Error) {
            URLProtocolStub.error = error
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            URLProtocolStub.requestObserver?(request)
            
            if let error = URLProtocolStub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
        
    // MARK: - Linux compatibility
    
    static var allTests = [
        ("test_getFromURL_performsGETRequestWithURL", test_getFromURL_performsGETRequestWithURL),
        ("test_getFromURL_failsOnRequestError", test_getFromURL_failsOnRequestError),
    ]
}
