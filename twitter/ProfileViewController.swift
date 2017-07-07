//
//  ProfileViewController.swift
//  twitter
//
//  Created by Michael Wornow on 7/5/17.
//  Copyright © 2017 Michael Wornow. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ProfileTweetCellDelegate, ComposeViewControllerDelegate {
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var profileBannerImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    var tweets: [Tweet] = []
    var user: User!
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var loadingMoreView:InfiniteScrollActivityView?
    var feedIsLoadingMoreData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up user details
        screenNameLabel.text = "@" + user.screenName!
        usernameLabel.text = user.name
        profileImageView.af_setImage(withURL: user.profileImage!)
        profileBannerImageView.af_setImage(withURL: user.profileBannerImage!)
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
        
        // Initialize a UIRefreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        mainView.insertSubview(refreshControl, at: 0)
        
        fetchTweets {
        }
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
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        let afterTweet = tweets[0]
        fetchTweets(afterTweet: afterTweet, append: true) {
            refreshControl.endRefreshing()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!feedIsLoadingMoreData) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height // Total height of table with all elements filled in (off screen too)
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height // Bounds is height of table currently on screen
            
            // When the user has scrolled past the threshold, start requesting
            if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging && tweets.count > 0) { // ContentOffset is how far user has scrolled the table view
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
    
    func fetchTweets(beforeTweet: Tweet? = nil, afterTweet: Tweet? = nil, append: Bool = false, completion: @escaping () -> ()) {
        APIManager.shared.getHomeTimeLine(beforeTweet: beforeTweet, afterTweet: afterTweet, completion: { (tweets, error) in
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

}
