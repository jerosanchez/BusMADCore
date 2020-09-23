//
//  Created by Jero Sánchez on 23/09/2020.
//

import Foundation
import BusMADCore

class HTTPClientSpy: HTTPClient {
    private var messages = [Message]()
    var requestedURLs: [URL] {
        messages.map { $0.url }
    }
    
    struct Message {
        let url: URL
        let completion: (HTTPClientResult) -> Void
    }

    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        messages.append(Message(url: url, completion: completion))
    }
    
    func complete(withError error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)!
        messages[index].completion(.success(data, response))
    }
}
