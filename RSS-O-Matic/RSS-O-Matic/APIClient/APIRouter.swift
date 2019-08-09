//
//  APIRouter.swift
//  Drink-O-Matic
//
//  Created by Ramiro Coll Doñetz on 01/08/2019.
//  Copyright © 2019 Ramiro Coll Doñetz. All rights reserved.
//

import Alamofire

enum APIRouter: URLRequestConvertible {
    
    case login(username:String, password:String)
    case register(username:String, password:String)
    case feeds
    case removeFeed(feedId: Int)
    case subscribeFeed(feedUrl: String)
    case articles(feedId: Int)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login, .register, .subscribeFeed:
            return .post
        case .feeds, .articles:
            return .get
        case .removeFeed:
            return .delete
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .login:
            return "/users/login"
        case .register:
            return "/users/register"
        case .feeds:
            return "/feeds"
        case .subscribeFeed:
            return "/feeds/add"
        case .removeFeed(let feedId):
            return "/feeds/\(feedId)"
        case .articles(let feedId):
            return "/feeds/\(feedId)/articles"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return [K.APIParameterKey.username: email, K.APIParameterKey.password: password]
        case .register(let email, let password):
            return [K.APIParameterKey.username: email, K.APIParameterKey.password: password]
        case .subscribeFeed(let feedUrl):
            return [K.APIParameterKey.url: feedUrl]
        case .feeds, .articles, .removeFeed:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try K.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue

        // Auth
        if let user = DataManager.shared().user {
            urlRequest.setValue("Bearer \(user.authToken)", forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
        }
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}

