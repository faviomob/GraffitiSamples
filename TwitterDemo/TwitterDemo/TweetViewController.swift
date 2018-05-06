//
// TweetViewController.swift
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

import UIKit
import Graffiti

/*
 Code setup sample.
 Code setup is useful because of easy detection of any API changes.
 For clarity here raw strings are used, but for robustness always use #selector to get property names (see below).
 TweetViewController.json contains an exact same setup. To check it, comment setup() method below
 and set 'restorationIdentifier' of this view controller to 'TweetViewController' in the Interface Builder.
*/

class TweetViewController: ContentViewController {
    
    @IBOutlet var tweetButton: UIBarButtonItem!
    @IBOutlet var textView: UITextView!
}

extension TweetViewController {
    
    // The rule for this setup is very simple - if you can't repeat it in IB or JSON, then don't write it.
    
    override func setup() {
        let tweetAction = BarButtonActionController()
        tweetAction.serviceProvider = TwitterService.client
        tweetAction.actionName = TwitterAction.tweet.name
        tweetAction.form = (view as! FormDisplayView)   // don't forget to set custom class for self.view to FormDisplayView
        tweetAction.form!.mandatoryFields = [textView]  // at least should be one mandatory field
        tweetAction.sender = tweetButton
        
        let tweetStatus = ActionStatusController()
        tweetStatus.actionName = tweetAction.actionName
        tweetStatus.alias = "tweetStatus"   // alias to access this object in bindings
        tweetStatus.elements = [tweetButton, textView]  // these elements will be updated on status changes according to bindings
        tweetStatus.errorMessage = NSLocalizedString("Tweet can't be tweeted so far.", comment: "") // show message in case of error
        
        textView.gx_fieldName = "text"  // this is form field name "$text" in action "tweet" (without $)
        textView.gx.identifier = "\(#selector(getter: TweetViewController.textView))" // "textView", using #selector against typos and changes
        
        // keep textView not editable while operation in progress
        textView.gx.addBinding(dictionary: [ObjectAssistant.bindTo: "gx_readOnly", ObjectAssistant.bindFrom: "tweetStatus.inProgress"])
        
        // reset textView value after operation succeeds, and re-assign its own value if isSuccess == 0 (during setup or when failed)
        textView.gx.addBinding(dictionary: [BindingOption.predicateFormat.rawValue: "tweetStatus.isSuccess == 1",
                                            BindingOption.valueIfTrue.rawValue: "",
                                            BindingOption.valueIfFalse.rawValue: "$textView.text"])
        
        // disable button while operation in progress
        tweetButton.gx.addBinding(dictionary: [ObjectAssistant.bindTo: "gx_disabled", ObjectAssistant.bindFrom: "tweetStatus.inProgress"])
        // dissmiss this view controller on success
        self.gx.addBinding(dictionary: [ObjectAssistant.bindTo: "gx_dismissed", ObjectAssistant.bindFrom: "tweetStatus.isSuccess"])
        
        self.objects = [tweetAction, tweetStatus]
        
        super.setup() // Ready set Go!
    }
}

extension TweetViewController {
    
//    override func outlet(_ object: NSObject, addedTo: NSObject, propertyKey: String, outletKey: String) {
//        print((addedTo.gx.identifier ?? "<unknown>") + "." + propertyKey + " = " + outletKey)
//    }
//
//    override func assigned(to target: NSObject, with identifier: String?, keyPath: String, source: NSObject, value: Any?, valueType: String, binding: NSObject) {
//        print("\(identifier ?? "<unknown>").\(keyPath) = \(value ?? "nil")")
//    }
}
