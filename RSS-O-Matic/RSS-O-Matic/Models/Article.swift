//
//  Article.swift
//  Networking
//
//  Created by Alaeddine Messaoudi on 26/11/2017.
//  Copyright © 2017 Alaeddine Me. All rights reserved.
//

import Foundation

struct ArticleList: Codable {
    let articles: [Article]
}

struct Article : Codable {
    let title: String
    let summary: String
    let url: String
    let articleId: Int
//    let datePublished: Date

//    "read_by": [],
//    "loaded": "2019-08-09T15:34:23.952862Z"
}

extension Article {
    //Customizing Key Names to match the naming style
    enum CodingKeys: String, CodingKey {
        case title = "title"
        case summary = "summary"
        case url = "url"
        case articleId = "id"
//        case datePublished = "date"
    }
}
