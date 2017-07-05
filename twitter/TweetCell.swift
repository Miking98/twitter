//
//  TweetCell.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit
import AlamofireImage
import TTTAttributedLabel

protocol TweetCellDelegate {
}

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tweetLabel: TTTAttributedLabel!
    
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet! {
        didSet {
            profileImageView.af_setImage(withURL: tweet.user.profileImage!, placeholderImage: #imageLiteral(resourceName: "profile-Icon"), runImageTransitionIfCached: true, completion: nil)
            nameLabel.text = tweet.user.name
            screenNameLabel.text = tweet.user.screenName
            dateLabel.text = tweet.createdAtString
            tweetLabel.text = tweet.text
            
            retweetLabel.text = String(format: "%d", tweet.retweetCount)
            favoriteLabel.text = String(format: "%d", tweet.favoriteCount)
            if (tweet.retweeted) {
                retweetButton.isSelected = true
            }
            if (tweet.favorited) {
                favoriteButton.isSelected = true
            }
        }
    }
    
    var delegate: TweetCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Style profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
        profileImageView.clipsToBounds = true;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    @IBAction func retweetButtonTouch(_ sender: UIButton) {
        var delta = 1;
        if retweetButton.isSelected {
            delta = -1;
        }
        APIManager.shared.retweetTweet(tweet: tweet, delta: delta) { (error: Error?) in
            if error != nil {
                print("Error retweeting this tweet")
                print(error!.localizedDescription)
            }
            else {
                self.retweetLabel.text = String(format: "%d", (Int(self.retweetLabel.text!) ?? 0) + delta)
                self.retweetButton.isSelected = !self.retweetButton.isSelected
            }
        }
    }
    
    @IBAction func favoriteButtonTouch(_ sender: UIButton) {
        var delta = 1;
        if favoriteButton.isSelected {
            delta = -1;
        }
        APIManager.shared.favoriteTweet(tweet: tweet, delta: delta) { (error: Error?) in
            if error != nil {
                print("Error favoriting this tweet")
                print(error!.localizedDescription)
            }
            else {
                self.favoriteLabel.text = String(format: "%d", (Int(self.favoriteLabel.text!) ?? 0) + delta)
                self.favoriteButton.isSelected = !self.favoriteButton.isSelected
            }
        }
    }
    
    
}
