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

    internal static func map(_ data: Data, with response: HTTPURLResponse) throws -> [RemoteNearestStop] {
        guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteNearestStopsLoader.Error.invalidData
        }
        
        switch root.code {
        case "01":
            if let nearestStops = root.data {
                return nearestStops
            } else {
                throw RemoteNearestStopsLoader.Error.invalidData
            }
        case "80": throw RemoteNearestStopsLoader.Error.expiredSession
        case "90": throw RemoteNearestStopsLoader.Error.invalidRequest
        default: throw RemoteNearestStopsLoader.Error.invalidData
        }
    }
}
