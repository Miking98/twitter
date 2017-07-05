//
//  DetailViewController.swift
//  twitter
//
//  Created by Michael Wornow on 7/5/17.
//  Copyright © 2017 Michael Wornow. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import AlamofireImage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var postLikesLabel: UILabel!
    @IBOutlet weak var postRetweetsLabel: UILabel!
    @IBOutlet weak var postUsernameLabel: UILabel!
    @IBOutlet weak var postScreenNameLabel: UILabel!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postContentLabel: TTTAttributedLabel!
    @IBOutlet weak var postProfileImageView: UIImageView!
    
    @IBOutlet weak var postRetweetButton: UIButton!
    @IBOutlet weak var postFavoriteButton: UIButton!
    
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postProfileImageView.af_setImage(withURL: tweet.user.profileImage!, placeholderImage: #imageLiteral(resourceName: "profile-Icon"), runImageTransitionIfCached: true, completion: nil)
        postUsernameLabel.text = tweet.user.name
        postScreenNameLabel.text = tweet.user.screenName
        postDateLabel.text = tweet.createdAtString
        postContentLabel.text = tweet.text
        
        postRetweetsLabel.text = String(format: "%d", tweet.retweetCount)
        postLikesLabel.text = String(format: "%d", tweet.favoriteCount)
        if (tweet.retweeted) {
            postRetweetButton.isSelected = true
        }
        if (tweet.favorited) {
            postFavoriteButton.isSelected = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func retweetButtonTouch(_ sender: UIButton) {
        var delta = 1;
        if postRetweetButton.isSelected {
            delta = -1;
        }
        APIManager.shared.retweetTweet(tweet: tweet!, delta: delta) { (error: Error?) in
            if error != nil {
                print("Error retweeting this tweet")
                print(error!.localizedDescription)
            }
            else {
                self.postRetweetsLabel.text = String(format: "%d", (Int(self.postRetweetsLabel.text!) ?? 0) + delta)
                self.postRetweetButton.isSelected = !self.postRetweetButton.isSelected
            }
        }
    }
    
    @IBAction func favoriteButtonTouch(_ sender: UIButton) {
        var delta = 1;
        if postFavoriteButton.isSelected {
            delta = -1;
        }
        APIManager.shared.favoriteTweet(tweet: tweet!, delta: delta) { (error: Error?) in
            if error != nil {
                print("Error favoriting this tweet")
                print(error!.localizedDescription)
            }
            else {
                self.postLikesLabel.text = String(format: "%d", (Int(self.postLikesLabel.text!) ?? 0) + delta)
                self.postFavoriteButton.isSelected = !self.postFavoriteButton.isSelected
            }
        }
    }
}
