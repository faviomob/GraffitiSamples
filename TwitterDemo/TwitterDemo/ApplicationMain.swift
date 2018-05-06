//
// ApplicationMain.swift
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
import CoreData
import Graffiti

/*
 * This sample demonstrates how you can create native codeless apps with Graffiti framework.
 * And mix it with some custom code if you need to.
 */

@UIApplicationMain
class ApplicationMain: UIResponder, UIApplicationDelegate, ObserversStorageProtocol { // 'AppDelegate' is an ugly name!
    
    var window: UIWindow?
    var observers: [Any] = []
    
    func setupObservers() {
        observers = [
            // After successful login call currentUser.
            TwitterAction.login.notification.onSuccess.subscribe { _ in
                TwitterAction.currentUser.perform()
            }
        ]
    }
    
    /*
     * Start your BundleIdentifier with `com.m8labs.graffiti.` to prevent Graffiti from showing its demo warning.
     * Uncomment line below in production and set your own license key and product permalink.
     * You can find them in your purchased subscription (graffiti.m8labs.com).
     */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        Graffiti.setLicenseKey("ABCDEFGH-ABCDEFGH-ABCDEFGH-ABCDEFGH", productPermalink: "GRAF0")
        setupObservers()
        TwitterService.client.setup()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        TwitterService.client.handleOpenUrl(url: url) // oauth
        return true
    }
}
