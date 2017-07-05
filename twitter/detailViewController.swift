//
//  detailViewController.swift
//  twitter
//
//  Created by Michael Wornow on 7/5/17.
//  Copyright © 2017 Michael Wornow. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import AlamofireImage

class detailViewController: UIViewController {

    @IBOutlet weak var postLikesLabel: UILabel!
    @IBOutlet weak var postRetweetsLabel: UILabel!
    @IBOutlet weak var postProfileImageView: UIImageView!
    @IBOutlet weak var postUsernameLabel: UILabel!
    @IBOutlet weak var postScreenNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postContentLabel: TTTAttributedLabel!
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let tweet = tweet {
            postLikesLabel.text = String(tweet.favoriteCount)
            postRetweetsLabel.text = String(tweet.retweetCount)
            postUsernameLabel.text = tweet.user.name
            postScreenNameLabel.text = tweet.user.screenName
            postContentLabel.text = tweet.text
            postProfileImageView.af_setImage(withURL: tweet.user.profileImage!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
