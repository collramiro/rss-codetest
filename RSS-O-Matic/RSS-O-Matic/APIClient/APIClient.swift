//
//  APIClient.swift
//  Drink-O-Matic
//
//  Created by Ramiro Coll Doñetz on 01/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import Alamofire

class APIClient {
    @discardableResult
    private static func performRequest<T:Decodable>(route:APIRouter, decoder: JSONDecoder = JSONDecoder(), completion:@escaping (AFResult<T>)->Void) -> DataRequest {
        return AF.request(route)
            .responseDecodable (decoder: decoder){ (response: DataResponse<T>) in
                completion(response.result)
        }
    }
    
    static func register(username: String, password: String, completion:@escaping (AFResult<User>)->Void) {
        performRequest(route: APIRouter.register(username: username, password: password), completion: completion)
    }
    
    static func login(username: String, password: String, completion:@escaping (AFResult<User>)->Void) {
        performRequest(route: APIRouter.login(username: username, password: password), completion: completion)
    }
    
    static func getFeeds(completion:@escaping (AFResult<[Feed]>)->Void) {
        let jsonDecoder = JSONDecoder()
        //        jsonDecoder.dateDecodingStrategy = .formatted(.articleDateFormatter)
        performRequest(route: APIRouter.feeds, decoder: jsonDecoder, completion: completion)
    }
    
    static func subscribeFeed(feedUrl: String, completion:@escaping (AFResult<Feed>)->Void) {
        let jsonDecoder = JSONDecoder()
        performRequest(route: APIRouter.subscribeFeed(feedUrl: feedUrl), decoder: jsonDecoder, completion: completion)
    }
    
    static func removeFeed(feedId: Int, completion:@escaping (AFResult<Bool>)->Void) {
        AF.request(APIRouter.removeFeed(feedId: feedId)).responseJSON { (response) in
            switch response.result {
            case .success:
                completion(.success(true))
            case .failure(let error):
                // error handling
                completion(.failure(error))
            }
        }
    }
    
    static func getArticles(feedId: Int, completion:@escaping (AFResult<ArticleList>)->Void) {
        let jsonDecoder = JSONDecoder()
        //        jsonDecoder.dateDecodingStrategy = .formatted(.articleDateFormatter)
        performRequest(route: APIRouter.articles(feedId: feedId), decoder: jsonDecoder, completion: completion)
    }
}


