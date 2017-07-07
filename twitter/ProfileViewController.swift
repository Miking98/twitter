//
//  ProfileViewController.swift
//  twitter
//
//  Created by Michael Wornow on 7/5/17.
//  Copyright © 2017 Michael Wornow. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ProfileTweetCellDelegate, ComposeViewControllerDelegate {
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerUsernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var profileBannerImageView:UIImageView!
    @IBOutlet weak var profileBannerBlurImageView:UIImageView!
    
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweets: [Tweet] = []
    var user: User!
    
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 95.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 35.0 // The distance between the bottom of the Header and the top of the White Label

    var loadingMoreView:InfiniteScrollActivityView?
    var feedIsLoadingMoreData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up user details
        screenNameLabel.text = "@" + user.screenName!
        usernameLabel.text = user.name
        profileImageView.af_setImage(withURL: user.profileImage!)
        bioLabel.text = user.bio
        followingLabel.text = String(describing: user.followingCount)
        followersLabel.text = String(describing: user.followersCount)
        websiteLabel.text = user.url
        locationLabel.text = user.location
        if user.verified! {
            verifiedImageView.isHidden = false
        }
        
        // Set up tweets table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        // Set up scroll view
        scrollView.delegate = self
        
        // Fetch user's profile tweets
        fetchTweets {
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Banner Image
        //// Load from URL
        Alamofire.request(user.profileBannerImage!)
            .responseImage { response in
                if let profileBannerImage = response.result.value {
                    //// Regular
                    self.profileBannerImageView = UIImageView(frame: self.headerView.bounds)
                    self.profileBannerImageView?.image = profileBannerImage
                    self.profileBannerImageView?.contentMode = UIViewContentMode.scaleAspectFill
                    self.headerView.insertSubview(self.profileBannerImageView, belowSubview: self.headerUsernameLabel)
                    //// Blurred
                    let profileBannerBlurImage = profileBannerImage.blurredImage(withRadius: 10, iterations: 20, tintColor: UIColor.clear)
                    self.profileBannerBlurImageView = UIImageView(frame: self.headerView.bounds)
                    self.profileBannerBlurImageView?.image = profileBannerBlurImage
                    self.profileBannerBlurImageView?.contentMode = UIViewContentMode.scaleAspectFill
                    self.profileBannerBlurImageView?.alpha = 0.0
                    self.headerView.insertSubview(self.profileBannerBlurImageView, belowSubview: self.headerUsernameLabel)
                }
        }
        headerView.clipsToBounds = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTweetCell", for: indexPath) as! ProfileTweetCell
        
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Animate header
        let offset = scrollView.contentOffset.y
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity
        
        
        if offset < 0 {
            // PULL DOWN
            
            // Animate header stretch and blur
            let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            headerView.layer.transform = headerTransform
            
            // Refresh
            let afterTweet: Tweet? = tweets.count>0 ? tweets[0] : nil
            fetchTweets(afterTweet: afterTweet, append: tweets.count > 0) {
                
            }
            
        }
        else {
            // SCROLL
            // Animate header switch to username
            //// Header
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            //// Username
            let labelTransform = CATransform3DMakeTranslation(0, max(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0)
            headerUsernameLabel.layer.transform = labelTransform
            //// Blur Banner Image
            profileBannerBlurImageView?.alpha = min (1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader)
            //// Avatar Scaling
            let avatarScaleFactor = (min(offset_HeaderStop, offset)) / profileImageView.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((profileImageView.bounds.height * (1.0 + avatarScaleFactor)) - profileImageView.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
            //// Avatar hide beneath header
            if offset <= offset_HeaderStop {
                if profileImageView.layer.zPosition < headerView.layer.zPosition{
                    headerView.layer.zPosition = 0
                }
            }
            else {
                if profileImageView.layer.zPosition >= headerView.layer.zPosition{
                    headerView.layer.zPosition = 2
                }
            }

            
            // Load more Tweets
            if (!feedIsLoadingMoreData) {
                // Calculate the position of one screen length before the bottom of the results
                let scrollViewContentHeight = tableView.contentSize.height // Total height of table with all elements filled in (off screen too)
                let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height // Bounds is height of table currently on screen
                
                // When the user has scrolled past the threshold, start requesting
                if (offset > scrollOffsetThreshold && tableView.isDragging && tweets.count > 0) { // ContentOffset is how far user has scrolled the table view
                    feedIsLoadingMoreData = true
                    // Update position of loadingMoreView, and start loading indicator
                    let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                    loadingMoreView?.frame = frame
                    loadingMoreView!.startAnimating()
                    //Fetch next posts
                    let mostAncientTweet = tweets[tweets.count-1]
                    fetchTweets(beforeTweet: mostAncientTweet, append: true, completion: {
                        self.feedIsLoadingMoreData = false
                        self.loadingMoreView!.stopAnimating()
                    })
                }
            }
        }
        // Apply transformations
        headerView.layer.transform = headerTransform
        profileImageView.layer.transform = avatarTransform
    }
    
    func fetchTweets(beforeTweet: Tweet? = nil, afterTweet: Tweet? = nil, append: Bool = false, completion: @escaping () -> ()) {
        APIManager.shared.getProfileTimeline(user: user, beforeTweet: beforeTweet, afterTweet: afterTweet, completion: { (tweets, error) in
            if let tweets = tweets {
                if (append) {
                    for t in tweets {
                        if beforeTweet != nil {
                            // If fetching older tweets, append to end of feed
                            self.tweets.append(t)
                        }
                        else if afterTweet != nil {
                            // If fetching more recent tweets, append to beginning of feed
                            self.tweets.insert(t, at: 0)
                        }
                    }
                }
                else {
                    self.tweets = tweets
                }
                self.tableView.reloadData()
            } else if let error = error {
                print("Error getting home timeline: " + error.localizedDescription)
            }
            completion()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "profileToProfile") {
            let viewSender = (sender as! UITapGestureRecognizer).view?.superview?.superview
            let cell = viewSender as! ProfileTweetCell
            let indexPath = tableView.indexPath(for: cell)!
            let tweet = tweets[indexPath.row]
            let vc = segue.destination as! ProfileViewController
            vc.user = tweet.user
        }
        else if (segue.identifier == "profileToDetail") {
            let cell = sender as! ProfileTweetCell
            let indexPath = tableView.indexPath(for: cell)!
            let vc = segue.destination as! DetailViewController
            vc.tweet = tweets[indexPath.row]
            print(vc.tweet)
        }
    }
    
    func did(post: Tweet) {
        tweets.insert(post, at: 0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

}
