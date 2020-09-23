//
//  Created by Jero Sánchez on 23/09/2020.
//

import Foundation

public enum LoadAccessTokenResult {
    case success(AccessToken)
    case failure(Error)
}

protocol AccessTokenLoader {
    func load(from url: URL, clientId: String, passKey: String, completion: @escaping (LoadAccessTokenResult) -> Void)
}
