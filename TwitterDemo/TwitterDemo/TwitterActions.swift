//
// TwitterActions.swift
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

/*
 These helper objects are to assist you in your custom code, and custom authentication process as well.
 */

enum TwitterAction: Notification.Name {
    /*
     Names here used to refer Service.json actions in 4 different ways:
     - action names in your code, such as TwitterAction.currentUser.perform()
     - action names in your storyboard or json files. It's just a string, such as "currentUser"
     - notifications of action status in you code, such as TwitterAction.currentUser.notification.onSuccess.subscribe {...}
     - notifications in your storyboard or json files, you must use it with notification suffix, such as "currentUserSuccess" or "currentUserError"
       See NetworkRequestStatusProtocol for possible values.
       For example:
         BaseContentController.reloadOn = "currentUserSuccess" (storyboard/json variant),
         BaseContentController.reloadOn = TwitterAction.currentUser.notification.onSuccess.rawValue (code type safe variant).
     
     You are not obligated to create these cases, it's only for convinience in your custom code. For example there is no "logout" case, because it's not used
     directly in the code, but there is custom action for this in TwitterActions class (see below).
     */
    case login
    case currentUser
    case homeTweets
    case moreTweets
    case prefetchTweets
    case tweet
}

extension TwitterAction {
    
    var name: String { return notification.rawValue }
    var notification: Notification.Name { return rawValue }
    /*
     Shortcut method for calling network actions.
     You can use completion to catch callback, but I encourage you not to do this.
     Instead, set observer via notification.onSuccess.subscribe {...}. See Application.swift for an example.
     */
    func perform(with object: Any? = nil, sender: Any? = nil, completion: Completion? = nil) {
        TwitterService.client.performAction(name, with: object, from: sender, completion: completion)
    }
}

class TwitterActions: CustomIBObject {
    /*
     Actions here resolved automatically in ActionController by constructing selectors from strings, f.e 'demo' will be resolved to demo(_:sender:).
     Also you can create action outlet to this object, just like action below.
     We could place this call into TweetsViewController.newsTap(_:), but what if you didn't know that you can connect several actions to one button?
     Now you know 😇
     Call showAll after timeout, because we should wait scrolling animation completion.
     */
    @IBAction func prefetchFeed(_ sender: Any?) {
        after(0.8) {
            Post.showAll()
        }
    }
}
