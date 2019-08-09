//
//  Drink.swift
//  Drink-O-Matic
//
//  Created by Ramiro Coll Doñetz on 01/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import Foundation
import UIKit

//struct FeedList: Codable {
//    let feeds: [Feed]
//}

struct Feed: Codable {
    let title: String
    let url: String
    let feedId: Int
}

extension Feed {
    //Customizing Key Names to match the naming style
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case url = "url"
        case feedId = "id"
    }
}
