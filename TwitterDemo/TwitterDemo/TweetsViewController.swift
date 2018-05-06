//
// TweetsViewController.swift
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
 Storyboard setup sample.
 Storyboard setup is useful for fast prototyping.
 TweetsViewController.json contains an exact same setup. To check it, remove all top level custom objects (except TwitterActions)
 and set 'restorationIdentifier' of this view controller to 'TweetsViewController' in the Interface Builder.
 */

class TweetsViewController: StandardViewController {
    
    // At this moment tasks like this can't be automated.
    // But this problem will be solved in the upcoming release of GraffitiKit.
    
    @IBAction func newsTap(_ sender: Any?) {
        tableView?.scrollToTop() // <- THIS guy is a bad one in our story! 😱
    }
}

/*
 Uncomment this to see how things work.
 Do not use these methods for anything except debugging.
 */

extension TweetsViewController: SchemeDiagnosticsProtocol {
    
//    func created(object: NSObject, identifier: String) {
//        print(identifier)
//    }
//
//    func outlet(_ object: NSObject, addedTo: NSObject, propertyKey: String, outletKey: String) {
//        print((addedTo.gx.identifier ?? "<unknown>") + "." + propertyKey + " = " + outletKey)
//    }
//
//    func binded(_ bindings: [NSObject], in container: NSObject) {
//        print("\(container.gx.identifier ?? "<unknown>") bindings: \(bindings.count)")
//    }
//
//    func assigned(to target: NSObject, with identifier: String?, keyPath: String, source: NSObject, value: Any?, valueType: String, binding: NSObject) {
//        print("\(identifier ?? "<unknown>").\(keyPath) = \(value ?? "nil")")
//    }
//
//    func beforeAction(_ action: String, content: Any?, sender: ActionController) {
//        print("Before \(action), content = \(String(describing: content))")
//    }
//
//    func afterAction(_ action: String, result: Any?, error: Error?, sender: ActionStatusController) {
//        print("After \(action), result = \(String(describing: result)), error = \(String(describing: error))")
//    }
}
