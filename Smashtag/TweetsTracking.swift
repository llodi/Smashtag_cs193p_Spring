//
//  TweetTracking.swift
//  Smashtag
//
//  Created by Ilya Dolgopolov on 01/07/16.
//  Copyright © 2016 Ilya Dolgopolov. All rights reserved.
//

import Foundation


class TweetsTracking {
    
    private struct Constant {
        static let ValuesKey = "TweetTracking.Values"
        static let MaxVisibleSearchingResult = 100
    }
    
    static let Tracking = TweetsTracking()
    
    let defaults = NSUserDefaults.standardUserDefaults
    
    var values: [String] {
        get { return defaults().objectForKey(Constant.ValuesKey) as? [String] ?? [] }
        set { defaults().setObject(newValue, forKey: Constant.ValuesKey) }
    }
    
    func add(search: String) {
        var currentResults = values
        
        if let index = currentResults.indexOf(search) {
            currentResults.removeAtIndex(index)
        }
        currentResults.insert(search, atIndex: 0)
        
        while currentResults.count > Constant.MaxVisibleSearchingResult {
            currentResults.removeLast()
        }
        
        values = currentResults
    }
    
    func removeAtIndex(index: Int) {
        var currentResults = values
        currentResults.removeAtIndex(index)
        values = currentResults
    }
}