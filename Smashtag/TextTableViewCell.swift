//
//  HashtagsTableViewCell.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 28.06.16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import UIKit
import Twitter

class TextTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var hashtagLabel: UILabel!
    
    var mention: Twitter.Mention? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI () {
        hashtagLabel?.text = nil
        hashtagLabel?.text = mention!.keyword
    }    
}
