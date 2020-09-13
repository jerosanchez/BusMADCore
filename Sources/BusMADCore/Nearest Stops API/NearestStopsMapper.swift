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
    
    private static var OK_200: Int { return 200 }
    
    private static var SUCCESS_CODE: String { return "00" }

    internal static func map(_ data: Data, with response: HTTPURLResponse) -> RemoteNearestStopsLoader.Result {
        if response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) {
            
            if let stops = (root.data?.map { $0.model }) {
                if root.code == SUCCESS_CODE {
                    return .success(stops)
                } else {
                    return .failure(RemoteNearestStopsLoader.Error.invalidRequest)
                }
            } else {
                return .failure(RemoteNearestStopsLoader.Error.expiredSession)
            }
            
        } else {
            return .failure(RemoteNearestStopsLoader.Error.invalidData)
        }
    }
}
