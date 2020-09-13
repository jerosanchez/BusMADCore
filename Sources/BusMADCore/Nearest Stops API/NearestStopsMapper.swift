//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

internal class NearestStopsMapper {
    private struct Root: Decodable {
        internal let code: String
        internal let description: String
        internal let data: [RemoteNearestStop]?
    }

    internal static func map(_ data: Data, with response: HTTPURLResponse) -> RemoteNearestStopsLoader.Result {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            
            if let stops = (root.data?.map { $0.model }) {
                return .success(stops)
            } else {
                if root.code == "80" {
                    return .failure(.expiredSession)
                } else {
                    return .failure(.invalidRequest)
                }
            }
            
        } else {
            return .failure(.invalidData)
        }
    }
}
