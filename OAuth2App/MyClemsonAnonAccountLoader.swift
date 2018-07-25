//
//  MyClemsonAnonAccountLoader.swift
//  OAuth2App
//
//  Created by Douglas Dawson on 7/25/18.
//  Copyright © 2018 Ossus. All rights reserved.
//

import Foundation
import OAuth2

extension String: Error {}
/**
 Simple class handling authorization and data requests with myClemson using Client Credentials.
 */
class MyClemsonAnonAccountLoader: OAuth2DataLoader, DataLoader {
    let apiURL = URL(string: "https://api-my.local.clemson.edu/api/v1/")!
    
    public init() {
        let oauth = OAuth2PasswordGrant(settings: [
            "client_id": "",
            "client_secret": "",
            "username": "",
            "password": "",
            "authorize_uri": "https://login-my.local.clemson.edu/authorize",
            "token_uri": "https://login-my.local.clemson.edu/token",
            "scope": "preferences",
            "verbose": true,
            ])
        super.init(oauth2: oauth)
    }
    
    
    /** Perform a request against the api and return decoded JSON or an NSError. */
    func request(path: String, callback: @escaping ((OAuth2JSON?, Error?) -> Void)) {
        oauth2.logger = OAuth2DebugLogger(.trace)
        let url = apiURL.appendingPathComponent(path)
        let req = oauth2.request(forURL: url)
        
        perform(request: req) { response in
            do {
                guard let d = response.data else {
                    throw "Argh"
                }
                print(String(data: d, encoding: String.Encoding.utf8))
                var dict = [String: Any]()
                dict["name"]="hi"
                DispatchQueue.main.async() {
                    callback(dict, nil)
                }
            }
            catch let error {
                print(error)
                DispatchQueue.main.async() {
                    callback(nil, error)
                }
            }
        }
    }
    
    func requestUserdata(callback: @escaping ((_ dict: OAuth2JSON?, _ error: Error?) -> Void)) {
        request(path: "me/subscriptions", callback: callback)
    }
}
