//
//  ComposeViewController.swift
//  twitter
//
//  Created by Michael Wornow on 7/3/17.
//  Copyright © 2017 Michael Wornow. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

protocol ComposeViewControllerDelegate {
    func did(post: Tweet)
}

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var contentTextView: RSKPlaceholderTextView!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    
    var delegate: ComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Focus text field
        contentTextView.becomeFirstResponder()
        contentTextView.delegate = self
        
        // Style Tweet button
        tweetButton.backgroundColor = UIColor.init(red: 224/255, green: 246/255, blue: 255/255, alpha: 1)
        tweetButton.layer.cornerRadius = 10
        
        // Style profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
        profileImageView.clipsToBounds = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        charCountLabel.textColor = UIColor.darkGray
        if (contentTextView.text.characters.count > 0 && contentTextView.text.characters.count <= 140) {
            tweetButton.isEnabled = true
            tweetButton.backgroundColor = UIColor.init(red: 0/255, green: 172/255, blue: 237/255, alpha: 1)
        }
        else {
            tweetButton.isEnabled = false
            tweetButton.backgroundColor = UIColor.init(red: 224/255, green: 246/255, blue: 255/255, alpha: 1)
        }
        let charsLeft = 140 - contentTextView.text.characters.count
        charCountLabel.text = String(charsLeft)
        if charsLeft < 20 {
            charCountLabel.textColor = UIColor.red
        }
    }

    @IBAction func tweetButtonTouch(_ sender: UIButton) {
        let tweetContent = contentTextView.text!
        APIManager.shared.postTweet(text: tweetContent) { (tweet: Tweet?, error: Error?) in
            if let error = error {
                print("Error posting tweet")
                print(error.localizedDescription)
            }
            else if let tweet = tweet {
                self.delegate?.did(post: tweet)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func dismissButtonTouch(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
