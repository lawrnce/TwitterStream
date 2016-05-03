//
//  TwitterStreamViewControllerTests.swift
//  TwitterStream
//
//  Created by lola on 5/3/16.
//  Copyright © 2016 LawrenceTran. All rights reserved.
//

import XCTest
import Nimble
@testable import TwitterStream

class TwitterStreamViewControllerTests: XCTestCase {
    
    var twitterStreamViewController: TwitterStreamViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.twitterStreamViewController = storyboard.instantiateViewControllerWithIdentifier("TwitterStreamVC") as! TwitterStreamViewController
        self.twitterStreamViewController.performSelectorOnMainThread(Selector("loadView"), withObject: nil, waitUntilDone: true)
    }
    
    override func tearDown() {
        self.twitterStreamViewController = nil
        super.tearDown()
    }
    
    // MARK: - Loading Tests
    
    /**
        View should be loaded.
     */
    func test_view_loads() {
        expect(self.twitterStreamViewController).to(beTruthy())
    }
    
    /**
        Table view should be a subview.
     */
    func test_parent_view_has_table_view_subview() {
        let subviews = self.twitterStreamViewController.view.subviews
        expect(subviews).to(contain(self.twitterStreamViewController.tableView))
    }
    
    /**
        Table view should be loaded.
     */
    func test_table_view_loads() {
        expect(self.twitterStreamViewController.tableView).to(beTruthy())
    }
    
    // MARK: - Table View Tests
    
    /**
        View controller should conform to table view data source.
     */
    func test_view_controller_should_conform_to_table_view_data_source() {
        expect(self.twitterStreamViewController.conformsToProtocol(UITableViewDataSource)).to(beTruthy())
    }
    
    /**
        Table view should have a datasource.
     */
    func test_table_view_should_have_data_source() {
        expect(self.twitterStreamViewController.tableView.dataSource).to(beTruthy())
    }
    
    /**
        View controller should conform to table view delegate.
     */
    func test_view_controller_should_conform_to_table_view_delegate() {
        expect(self.twitterStreamViewController.conformsToProtocol(UITableViewDelegate)).to(beTruthy())
    }
    
    /**
        Table view should have a delegate.
     */
    func test_table_view_should_have_delegate() {
        expect(self.twitterStreamViewController.tableView.delegate).to(beTruthy())
    }
}