//
// Post.swift
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

import Graffiti

extension Post {
    
    static let dateFormatter = DateFormatter()
    /*
     This property is used by TweetDetailsViewController for binding text of the dateLabel.
     Always place you data presentation logic in your model extensions. In this case you can refer to these properties via key path from xib/json.
     */
    @objc var timestampString: String? {
        Post.dateFormatter.timeStyle = .medium
        Post.dateFormatter.dateStyle = .long
        let str = Post.dateFormatter.string(from: timestamp! as Date)
        return str
    }
    
    func timeAgoString(from date: Date) -> String {
        let interval = date.timeIntervalSinceNow
        let intervalInt = Int(interval) * -1
        let days = (intervalInt / 3600) / 24
        if days != 0 {
            let daysStr = String(days) + NSLocalizedString("d", comment: "Shortest abbreviation of a day.")
            return daysStr
        }
        let hours = (intervalInt / 3600)
        if hours != 0 {
            return String(hours) + NSLocalizedString("h", comment: "Shortest abbreviation of an hour.")
        }
        let minutes = (intervalInt / 60) % 60
        if minutes != 0 {
            return String(minutes) + NSLocalizedString("m", comment: "Shortest abbreviation of a minute.")
        }
        let seconds = intervalInt % 60
        if seconds != 0 {
            return String(seconds) + NSLocalizedString("s", comment: "Shortest abbreviation of a second.")
        } else {
            return NSLocalizedString("Now", comment: "Just happened. Less than a second ago.")
        }
    }
    
    @objc var timeAgoString: String? {
        return timeAgoString(from: timestamp!)
    }
}

extension Post {
    
    static func show(_ posts: [Post]?) {
        posts?.forEach { post in
            post.isHidden = false
        }
    }
    /*
     Avoid using selectors strings in your code, refer to them through #selector mechanism.
     */
    static func showAll() {
        show(Post.objects(with: IF("\(#selector(getter: Post.isHidden)) = 1")))
    }
}
