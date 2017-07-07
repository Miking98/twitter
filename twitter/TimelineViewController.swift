//
//  TimelineViewController.swift
//  twitter_alamofire_demo
//
//  Created by Charles Hieger on 6/18/17.
//  Copyright © 2017 Charles Hieger. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetCellDelegate, ComposeViewControllerDelegate {
    
    var tweets: [Tweet] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var loadingMoreView:InfiniteScrollActivityView?
    var feedIsLoadingMoreData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up home feed table view
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
        tableView.insertSubview(refreshControl, at: 0)
        
        fetchTweets {
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        
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
    
    
    @IBAction func didTapLogout(_ sender: Any) {
        APIManager.shared.logout()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "homeToCompose") {
            let vc = segue.destination as! ComposeViewController
            vc.delegate = self
        }
        else if (segue.identifier == "homeToDetail") {
            let cell = sender as! TweetCell
            let indexPath = tableView.indexPath(for: cell)!
            let tweet = tweets[indexPath.row]
            let vc = segue.destination as! DetailViewController
            vc.tweet = tweet
        }
        else if (segue.identifier == "homeToProfile") {
            let cell = sender as! TweetCell
            let indexPath = tableView.indexPath(for: cell)!
            let tweet = tweets[indexPath.row]
            let vc = segue.destination as! ProfileViewController
            vc.user = tweet.user
        }
    }
    
    func did(post: Tweet) {
        tweets.insert(post, at: 0)
    }
    
    
}
