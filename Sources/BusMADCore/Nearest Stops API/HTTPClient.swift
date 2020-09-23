//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
    func get(from url: URL, headers: [String: String], completion: @escaping (HTTPClientResult) -> Void)
}
