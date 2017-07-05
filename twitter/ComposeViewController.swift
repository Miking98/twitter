//
//  ComposeViewController.swift
//  twitter
//
//  Created by Michael Wornow on 7/3/17.
//  Copyright © 2017 Michael Wornow. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var contentTextView: RSKPlaceholderTextView!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Focus text field
        contentTextView.becomeFirstResponder()
        contentTextView.delegate = self
        
        // Style Tweet button
        tweetButton.backgroundColor = UIColor.init(red: 0/255, green: 172/255, blue: 237/255, alpha: 1)
        tweetButton.layer.cornerRadius = 10
        
        // Style profile image
        profileImageView.backgroundColor = .clear
        profileImageView.layer.cornerRadius = 100
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.black.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textViewDidChange(_ textView: UITextView) { //Handle the text changes here
        charCountLabel.textColor = UIColor.darkGray
        print(contentTextView.text.characters.count)
        if (contentTextView.text.characters.count > 0 && contentTextView.text.characters.count <= 140) {
            tweetButton.isEnabled = true
        }
        else {
            tweetButton.isEnabled = false
        }
        let charsLeft = 140 - contentTextView.text.characters.count
        charCountLabel.text = String(charsLeft)
        if charsLeft < 20 {
            charCountLabel.textColor = UIColor.red
        }
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
