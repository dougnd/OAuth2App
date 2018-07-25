//
//  MyClemsonClientCredentials.swift
//  OAuth2App
//
//  Created by Douglas Dawson on 7/25/18.
//  Copyright © 2018 Ossus. All rights reserved.
//

import Foundation
import OAuth2


/**
 Simple class handling authorization and data requests with myClemson using Client Credentials.
 */
class MyClemsonClientCredentials: OAuth2DataLoader, DataLoader {
    let apiURL = URL(string: "https://api-my.local.clemson.edu/api/v1/")!
    
    public init() {
        let oauth = OAuth2ClientCredentials(settings: [
            "client_id": "",
            "client_secret": "",
            "authorize_uri": "https://login-my.local.clemson.edu/authorize",
            "token_uri": "https://login-my.local.clemson.edu/token",
            "scope": "create_anon",
            "verbose": true,
            ])
        super.init(oauth2: oauth)
    }
    
    
    /** Perform a request against the GitHub API and return decoded JSON or an NSError. */
    func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
        oauth2.logger = OAuth2DebugLogger(.trace)
        let url = apiURL.appendingPathComponent(path)
        var req = oauth2.request(forURL: url)
        req.httpMethod = "POST"
        
        perform(request: req) { response in
            do {
                var dict = try response.responseJSON()
                print(dict)
                dict["name"]=dict["username"]
                DispatchQueue.main.async() {
                    callback(dict, nil)
                }
            }
            catch let error {
                DispatchQueue.main.async() {
                    callback(nil, error)
                }
            }
        }
    }
    
    func requestUserdata(callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void)) {
        request(path: "anon/create", callback: callback)
    }
}
