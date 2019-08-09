//
//  User.swift
//  RSS-O-Matic
//
//  Created by Ramiro Coll Doñetz on 09/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import Foundation

class User: Codable {
    let authToken: String
    let userId: Int
}

extension User {
    //Customizing Key Names to match the naming style
    enum CodingKeys: String, CodingKey {
        case authToken = "access_token"
        case userId = "user_id"
    }
}
