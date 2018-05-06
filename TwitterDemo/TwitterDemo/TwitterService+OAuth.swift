//
// TwitterService+OAuth.swift
// Graffiti Samples
//
// BSD License
// Copyright © 2018, M8 Labs (m8labs.com). All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import CoreData
import Graffiti

class TwitterConfiguration: StandardServiceConfiguration {
    
    var consumerKey: String {
        let value = authParameters["consumerKey"] as? String
        precondition(value != nil && value!.isEmpty == false, "Get your own ConsumerKey at https://apps.twitter.com")
        return value!
    }
    
    var consumerSecret: String {
        let value = authParameters["consumerSecret"] as? String
        precondition(value != nil && value!.isEmpty == false, "Get your own ConsumerSecret at https://apps.twitter.com")
        return value!
    }
    
    var requestTokenPath : String { return authParameters["requestTokenPath"] as! String }
    var accessTokenPath  : String { return authParameters["accessTokenPath"]  as! String }
    var callbackUrl      : String { return authParameters["callbackUrl"]      as! String }
}

/*
 This is how you can integrate custom authentication process to Graffiti. You can use any library for this purpose.
 See BDBOAuth1SessionManager documentation for details on what's happening here.
 */

extension TwitterService {
    /*
     Actions here resolved automatically in ActionController by constructing selectors from strings, f.e 'logout' will be resolved to logout(_:sender:).
     Parameter 'content' here is taken from 'content' property of ActionController (from which methods below called). But in these two cases 'content' doesn't matter.
     If selector not found, TwitterService.performAction(action, with: content, from: sender) will be called instead.
     */
    @objc func login(_ content: Any?, sender: Any?) {
        TwitterService.oAuth.deauthorize()
        TwitterAction.login.notification.onStart.post()
        TwitterService.oAuth.fetchRequestToken(withPath: config.requestTokenPath,
                                               method: "GET", callbackURL: config.callbackUrl.asURL, scope: nil, success: { requestToken in
            guard let token = requestToken?.token else { print("Empty token!"); return }
            let url = self.config.authUrl!.replacingOccurrences(of: "$token", with: token)
            UIApplication.shared.open(url.asURL!, options: [:], completionHandler: nil)
        }, failure: { error in
            debugPrint(error ?? "Not an error!")
            TwitterAction.login.notification.onError.post(error: error)
        })
    }
    
    @objc func logout(_ content: Any?, sender: Any?) {
        TwitterService.oAuth.deauthorize()
        Account.clear()
        Post.clear()
        TwitterAction.currentUser.notification.onError.post() // Auth window shoud be shown on this notification. Will be handled automatically in the future release.
    }
}

extension TwitterService {
    
    var config: TwitterConfiguration { return configuration as! TwitterConfiguration }
    
    static var oAuth: BDBOAuth1SessionManager! = {
        return BDBOAuth1SessionManager(baseURL: client.config.baseUrl!.asURL, consumerKey: client.config.consumerKey, consumerSecret: client.config.consumerSecret)
    }()
    
    func handleOpenUrl(url: URL) {
        let token = BDBOAuth1Credential(queryString: url.query)
        TwitterService.oAuth.fetchAccessToken(withPath: config.accessTokenPath, method: "POST", requestToken: token, success: { accessToken in
            debugPrint("Access token received: \(accessToken!)")
            TwitterAction.login.notification.onSuccess.post()
        }, failure: { error in
            debugPrint(error ?? "Not an error!")
            TwitterAction.login.notification.onError.post(error: error)
        })
    }
}
