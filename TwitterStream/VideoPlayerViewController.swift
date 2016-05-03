//
//  VideoPlayerViewController.swift
//  TwitterStream
//
//  Created by lola on 5/2/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import UIKit
import MediaPlayer

class VideoPlayerViewController: UIViewController {

    var moviePlayer: MPMoviePlayerController!
    var url: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        moviePlayer = MPMoviePlayerController(contentURL: url)
        moviePlayer.view.frame = self.view.bounds
        
        self.view.addSubview(moviePlayer.view)
        moviePlayer.fullscreen = true
        moviePlayer.controlStyle = .Fullscreen
   
        // Set notification for done button
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("donePressed:"), name: MPMoviePlayerPlaybackDidFinishNotification, object: self.moviePlayer)
    }

    // Selector
    func donePressed(notification: NSNotification) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // Stop video when view closes
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.moviePlayer.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}