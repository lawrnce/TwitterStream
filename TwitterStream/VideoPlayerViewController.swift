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
        moviePlayer.view.frame = CGRect(x: 0, y: 0, width: kSCREEN_, height: <#T##CGFloat#>)
        
        self.view.addSubview(moviePlayer.view)
        moviePlayer.fullscreen = true
        moviePlayer.controlStyle = .Embedded
        
        // disable swipe back
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}