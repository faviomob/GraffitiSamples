//
// TwitterService.swift
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

import Groot
import Alamofire
import Graffiti

/*
 Basically, this is all your network stack (not including custom authentication and Service.json).
 No more tons of small files, or single huge.
 */

class TwitterService: StandardServiceProvider {
    
    static var client = TwitterService()
    
    override func setup() {
        let config = TwitterConfiguration("Service.json")
        /*
         This is how you can integrate custom auth process to Graffiti. You can use any library for your authentication.
         All you need to do is to construct URLRequest in this closure.
         */
        config.setRequestComposer { action, method, url, body, headers in
            if config.needAuth(for: action) {
                let request = TwitterService.oAuth.requestSerializer.request(withMethod: method.rawValue, urlString: url, parameters: body, error: nil)
                return request as URLRequest
            }
            return nil
        }
        configuration = config
        printFullResponse = false
    }
    /*
     Override to handle errors from your service. You must return either Error or nil.
     Do not show error messages here to the user, there is another place for this - view controller's handleError(_:sender:) method (which shows alert by default).
     */
    override func serverError(from code: Int, with data: Data?) -> Error? {
        guard code != 200 else { return nil }
        switch code {
        case 404:
            return NSError(domain: errorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: "404: Action not found."])
        case 429:
            return NSError(domain: errorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: "Too many requests!"])
        default:
            if let json = data?.jsonDictionary() {
                if let message = json["error"] as? String {
                    return NSError(domain: errorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
                } else if let errors = json["errors"] as? [JSONDictionary] {
                    let combinedMessage = NSLocalizedString("Server errors:\n", comment: "") + errors.map({ $0["message"] as! String }).joined(separator: "\n")
                    return NSError(domain: errorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: combinedMessage])
                }
            }
        }
        return NSError(domain: errorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
    }
}

/*
 Uncomment this to see how things work.
 Do not use these methods for anything except debugging.
 */
extension TwitterService {

//    override func before(action: String, request: URLRequest) {
//        super.before(action: action, request: request)
//    }
//
//    override func after(action: String, request: URLRequest?, response: URLResponse?, data: Data?) {
//        super.after(action: action, request: request, response: response, data: data)
//    }
}
