//
//  PRSlideViewPage.swift
//  PRSlideViewDemo
//
//  Created by Elethom Hunter on 24/01/2015.
//  Copyright (c) 2015 Project Rhinestone. All rights reserved.
//

import UIKit

@objc public class PRSlideViewPage: UIControl {
    public var pageIndex: Int?
    public var pageIdentifier: String
    
    required public init(frame: CGRect, identifier: String) {
        self.pageIdentifier = identifier
        super.init(frame: frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
