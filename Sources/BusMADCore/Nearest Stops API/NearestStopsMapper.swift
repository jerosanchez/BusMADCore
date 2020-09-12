//
//  Created by Jero Sánchez on 12/09/2020.
//

import Foundation

internal class NearestStopsMapper {
    private struct Root: Decodable {
        internal let data: [RemoteNearestStop]
    }

    internal static func map(_ data: Data, with response: HTTPURLResponse) -> RemoteNearestStopsLoader.Result {
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            return .success(root.data.map { $0.model })
        } else {
            return .failure(.invalidData)
        }
    }
}
