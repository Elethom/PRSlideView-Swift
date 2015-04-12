//
//  ViewController.swift
//  PRSlideViewDemo
//
//  Created by Elethom Hunter on 24/01/2015.
//  Copyright (c) 2015 Project Rhinestone. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PRSlideViewDelegate, PRSlideViewDataSource {
    var albumData: [String] = [
        "Gorillaz",
        "G-Sides",
        "Laika Come Home",
        "Demon Days",
        "D-Sides (Special Edition)",
        "Plastic Beach",
        "The Fall",
        "The Singles Collection 2001-2011",
    ]
    
    @IBOutlet var slideView: PRSlideView!
    @IBOutlet var titleLabel: UILabel!
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slideView.delegate = self
        slideView.dataSource = self
        slideView.scrollDirection = .Vertical
        slideView.infiniteScrollingEnabled = true
        slideView.registerClass(
            PRAlbumPage.self,
            identifier: PRAlbumPage.description()
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        slideView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: PRSlideViewDelegate
    
    func slideView(slideView: PRSlideView, didScrollToPageAtIndex index: Int) {
        self.titleLabel.text = self.albumData[index]
    }
    
    func slideView(slideView: PRSlideView, didClickPageAtIndex index: Int) {
        let alertView: UIAlertView = UIAlertView(
            title: "You clicked on an album",
            message: "Title: \(self.albumData[index])",
            delegate: nil,
            cancelButtonTitle: "OK")
        alertView.show()
    }
    
    // MARK: PRSlideViewDataSource
    
    func numberOfPagesInSlideView(slideView: PRSlideView) -> Int {
        return self.albumData.count
    }
    
    func slideView(slideView: PRSlideView, pageAtIndex index: Int) -> PRSlideViewPage {
        let page: PRAlbumPage = slideView.dequeueReusablePageWithIdentifier(PRAlbumPage.description(), index: index) as! PRAlbumPage
        
        let imageName: String = self.albumData[index].stringByAppendingPathExtension("jpg")!
        page.coverImageView.image = UIImage(named: imageName)
        
        return page
    }
    
    // MARK: Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

