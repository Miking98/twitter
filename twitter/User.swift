//
//  User.swift
//  twitter_alamofire_demo
//
//  Created by Michael Wornow on 6/17/17.
//  Copyright © 2017 Michael Wornow. All rights reserved.
//

import Foundation

class User {
    
    private static var _current: User?
    static var current: User? {
        get {
            if _current == nil {
                let defaults = UserDefaults.standard
                if let userData = defaults.data(forKey: "currentUserData") {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! [String: Any]
                    _current = User(dictionary: dictionary)
                }
            }
            return _current
        }
        set (user) {
            _current = user
            let defaults = UserDefaults.standard
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.removeObject(forKey: "currentUserData")
            }
        }
    }
    
    var name: String
    var screenName: String?
    var dictionary: [String: Any]?
    var profileImage: URL?
    var profileBannerImage: URL?
    var bio: String?
    var followersCount: Int?
    var followingCount: Int?
    var location: String?
    var url: String?
    var verified: Bool?
    
    
    init(dictionary: [String: Any]) {
        self.dictionary = dictionary
        name = dictionary["name"] as! String
        screenName = dictionary["screen_name"] as? String
        profileImage = URL(string: dictionary["profile_image_url_https"] as? String ?? "")
        profileBannerImage = URL(string: dictionary["profile_banner_url"] as? String ?? "")
        bio = dictionary["description"] as? String
        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        location = dictionary["location"] as? String
        url = dictionary["url"] as? String
        verified = dictionary["verified"] as? Bool
    }
}
