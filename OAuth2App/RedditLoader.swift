//
//  RedditLoader.swift
//  OAuth2App
//
//  Created by Pascal Pfiffner on 3/27/15.
//  CC0, Public Domain
//

import Cocoa
import OAuth2


/**
	Simple class handling authorization and data requests with Reddit.
 */
class RedditLoader
{
	class var sharedInstance: RedditLoader {
		struct Static {
			static let instance = RedditLoader()
		}
		return Static.instance
	}
	
	class func handleRedirectURL(url: NSURL) {
		self.sharedInstance.oauth2.handleRedirectURL(url)
	}
	
	
	// MARK: - Instance
	
	let baseURL = NSURL(string: "https://oauth.reddit.com")!
	
	lazy var oauth2 = OAuth2CodeGrantBasicAuth(settings: [
		"client_id": "IByhV1ZcpTI6zQ",                              // yes, this client-id will work!
		"client_secret": "",
		"authorize_uri": "https://www.reddit.com/api/v1/authorize",
		"token_uri": "https://www.reddit.com/api/v1/access_token",
		"scope": "identity",                                        // note that reddit uses comma-separated, not space-separated scopes!
		"redirect_uris": ["ppoauthapp://oauth/callback"],           // app has registered this scheme
	])
	
	/** Start the OAuth dance. */
	func requestToken(callback: (wasFailure: Bool, error: NSError?) -> Void) {
		oauth2.verbose = true
		oauth2.afterAuthorizeOrFailure = callback
		
		let url = oauth2.authorizeURL()
		NSWorkspace.sharedWorkspace().openURL(url)
	}
	
	/** Perform a request against the API and return decoded JSON or an NSError. */
	func request(path: String, callback: ((dict: NSDictionary?, error: NSError?) -> Void)) {
		let url = baseURL.URLByAppendingPathComponent(path)
		let req = oauth2.request(forURL: url)
		
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(req) { data, response, error in
			if nil != error {
				dispatch_async(dispatch_get_main_queue(), {
					callback(dict: nil, error: error)
				})
			}
			else {
				var err: NSError?
				let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as? NSDictionary
				dispatch_async(dispatch_get_main_queue(), {
					callback(dict: dict, error: err)
				})
			}
		}
		task.resume()
	}
	
	
	// MARK: - Convenience
	
	func requestUserdata(callback: ((dict: NSDictionary?, error: NSError?) -> Void)) {
		request("api/v1/me", callback: callback)
	}
}
