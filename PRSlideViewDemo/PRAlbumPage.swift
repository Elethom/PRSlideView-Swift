//
//  PRAlbumPage.swift
//  PRSlideViewDemo
//
//  Created by Elethom Hunter on 25/01/2015.
//  Copyright (c) 2015 Project Rhinestone. All rights reserved.
//

import UIKit

public class PRAlbumPage: PRSlideViewPage {
    public private(set) var coverImageView: UIImageView
    
    required public init(frame: CGRect, identifier: String) {
        self.coverImageView = UIImageView()
        
        super.init(frame: frame, identifier: identifier)
        
        let coverImageView = self.coverImageView
        coverImageView.frame = self.bounds
        coverImageView.autoresizingMask = (.FlexibleWidth | .FlexibleHeight)
        coverImageView.contentMode = .ScaleAspectFit
        self.addSubview(coverImageView)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
