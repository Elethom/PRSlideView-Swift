//
//  PRSlideView.swift
//  PRSlideViewDemo
//
//  Created by Elethom Hunter on 24/01/2015.
//  Copyright (c) 2015 Project Rhinestone. All rights reserved.
//

import UIKit

let kPRSlideViewBufferLength: Int = 512

public enum PRSlideViewScrollDirection : Int {
    case Horizontal
    case Vertical
}

// MARK: - PRSlideViewDataSource

public protocol PRSlideViewDataSource : NSObjectProtocol {
    func numberOfPagesInSlideView(slideView: PRSlideView) -> Int
    func slideView(slideView: PRSlideView, pageAtIndex index: Int) -> PRSlideViewPage
}

// MARK: - PRSlideViewDelegate

@objc public protocol PRSlideViewDelegate : UIScrollViewDelegate, NSObjectProtocol {
    optional func slideView(slideView: PRSlideView, didScrollToPageAtIndex index: Int)
    optional func slideView(slideView: PRSlideView, didClickPageAtIndex index: Int)
}

// MARK: - PRSlideView

public class PRSlideView: UIScrollView {
    
    // MARK: Public properties
    
    public weak var dataSource: PRSlideViewDataSource?
    public var scrollDirection: PRSlideViewScrollDirection = .Horizontal
    public var infiniteScrollingEnabled: Bool = false
    
    public private(set) var numberOfPages: Int = 0 {
        didSet {
            if oldValue != numberOfPages {
                self.baseIndexOffset = self.infiniteScrollingEnabled ? numberOfPages * kPRSlideViewBufferLength / 2 : 0
                self.resizeContent()
            }
        }
    }
    
    public var currentPageIndex: Int {
        get {
            return self.indexForActualIndex(self.currentPageActualIndex)
        }
    }
    
    // MARK: Private properties
    
    var currentPageActualIndex: Int = 0 {
        didSet {
            if oldValue != currentPageActualIndex {
                if !self.isResizing {
                    self.didScrollToPageAtIndex(currentPageActualIndex)
                }
            }
        }
    }
    var baseIndexOffset: Int = 0
    
    var classForIdentifiers: [String: PRSlideViewPage.Type] = [String: PRSlideViewPage.Type]()
    var reusablePages: [String: [PRSlideViewPage]] = [String: [PRSlideViewPage]]()
    var loadedPages: [PRSlideViewPage] = [PRSlideViewPage]()
    
    var isResizing: Bool = false
    
    // MARK: Overrides
    
    override public var contentOffset: CGPoint {
        willSet {
            if contentOffset != newValue {
                let scrollDirection: PRSlideViewScrollDirection = self.scrollDirection
                let bounds: CGRect = self.bounds
                let width: CGFloat = CGRectGetWidth(bounds)
                let height: CGFloat = CGRectGetHeight(bounds)
                let index: Int = {
                    switch scrollDirection {
                    case .Horizontal:
                        return Int((newValue.x + width * 0.5) / width)
                    case .Vertical:
                        return Int((newValue.y + height * 0.5) / height)
                    }
                }()
                self.currentPageActualIndex = index
            }
        }
    }
    
    var preservedCurrentPageActualIndex: Int = 0
    
    func willResize() {
        self.isResizing = true
        self.preservedCurrentPageActualIndex = self.currentPageActualIndex
    }
    
    func didResize() {
        self.currentPageActualIndex = self.preservedCurrentPageActualIndex
        self.resizeContent()
        self.scrollToPageAtActualIndex(currentPageActualIndex, animated: false)
        self.isResizing = false
    }
    
    override public var frame: CGRect {
        get {
            return super.frame
        }
        set {
            self.willResize()
            
            super.frame = newValue
            
            self.didResize()
        }
    }
    
    // MARK: Create pages
    
    public func dequeueReusablePageWithIdentifier(identifier: String, index: Int) -> AnyObject {
        let frame: CGRect = self.rectForPageAtIndex(index)
        let reusablePage: PRSlideViewPage = {
            var reusablePagesForIdentifier = self.reusablePages[identifier]
            let reusablePage: PRSlideViewPage? = (reusablePagesForIdentifier != nil && !reusablePagesForIdentifier!.isEmpty) ? reusablePagesForIdentifier?.removeLast() : nil
            reusablePage?.frame = frame
            return reusablePage
            }() ?? self.classForIdentifiers[identifier]!.init(frame: frame, identifier: identifier)
        reusablePage.pageIndex = index
        return reusablePage
    }
    
    public func registerClass(pageClass: PRSlideViewPage.Type, identifier: String) {
        self.classForIdentifiers[identifier] = pageClass
    }
    
    // MARK: Access pages
    
    public func pageAtIndex(index: Int) -> PRSlideViewPage? {
        for page in self.loadedPages {
            if page.pageIndex == index {
                return page
            } else if page.pageIndex > index {
                return nil
            }
        }
        return nil
    }
    
    public func indexForPage(page: PRSlideViewPage) -> Int {
        return page.pageIndex!
    }
    
    public var visiblePages: [PRSlideViewPage] {
        get {
            return self.loadedPages
        }
    }
    
    // MARK: Scroll
    
    public func scrollToPageAtIndex(index: Int) {
        self.scrollToPageAtIndex(index, animated: true)
    }
    
    public func scrollToPageAtIndex(index: Int, animated: Bool) {
        self.scrollToPageAtActualIndex(self.actualIndexInCurrentLoopForIndex(index), animated: animated)
    }
    
    public func scrollToPageAtIndex(index: Int, forward: Bool, animated: Bool) {
        let actualIndex: Int = self.infiniteScrollingEnabled ? self.actualIndexForIndex(index, forward: forward) : index
        self.scrollToPageAtActualIndex(actualIndex, animated: animated)
    }
    
    func scrollToPageAtActualIndex(actualIndex: Int) {
        self.scrollToPageAtActualIndex(actualIndex, animated: true)
    }
    
    func scrollToPageAtActualIndex(actualIndex: Int, animated: Bool) {
        self.setContentOffset(self.rectForPageAtIndex(actualIndex).origin, animated: animated)
    }
    
    func actualIndexInCurrentLoopForIndex(index: Int) -> Int {
        if !self.infiniteScrollingEnabled {
            return index
        }
        return self.currentPageActualIndex - self.currentPageIndex + index
    }
    
    // MARK: Data
    
    public func reloadData() {
        self.removePagesOutOfIndexRange(NSMakeRange(0, 0))
        
        self.numberOfPages = self.dataSource!.numberOfPagesInSlideView(self)
        if self.infiniteScrollingEnabled && self.currentPageIndex == 0 {
            self.scrollToPageAtActualIndex(self.baseIndexOffset, animated: false)
        } else {
            self.didScrollToPageAtIndex(self.currentPageActualIndex)
        }
    }
    
    func addPagesOfIndexRange(var indexRange: NSRange) {
        if (!self.infiniteScrollingEnabled) {
            indexRange = NSIntersectionRange(indexRange, NSMakeRange(0, self.numberOfPages))
        }
        for pageIndex: Int in indexRange.location ..< NSMaxRange(indexRange) {
            if self.pageAtIndex(pageIndex) == nil {
                let page: PRSlideViewPage = self.dataSource!.slideView(self, pageAtIndex: self.indexForActualIndex(pageIndex))
                page.addTarget(self, action: #selector(PRSlideView.pageClicked(_:)), forControlEvents: .TouchUpInside)
                page.pageIndex = pageIndex
                
                if self.loadedPages.indexOf(page) == nil {
                    var inserted: Bool = false
                    for targetIdx: Int in 0 ..< self.loadedPages.count {
                        if self.loadedPages[targetIdx].pageIndex > pageIndex {
                            self.loadedPages.insert(page, atIndex: targetIdx)
                            inserted = true
                            break
                        }
                    }
                    if !inserted {
                        self.loadedPages.append(page)
                    }
                }
                
                page.frame = self.rectForPageAtIndex(pageIndex)
                page.autoresizingMask = ([.FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin])
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.addSubview(page)
                })
            }
        }
    }
    
    func removePagesOutOfIndexRange(var indexRange: NSRange) {
        if !self.infiniteScrollingEnabled {
            indexRange = NSIntersectionRange(indexRange, NSMakeRange(0, self.numberOfPages))
        }
        self.loadedPages = self.loadedPages.filter { (page: PRSlideViewPage) -> Bool in
            let pageIndex: Int = page.pageIndex!
            if !NSLocationInRange(pageIndex, indexRange) {
                let pageIdentifier: String = page.pageIdentifier
                var pages: [PRSlideViewPage] = self.reusablePages[pageIdentifier] ?? {
                    let pages: [PRSlideViewPage] = [PRSlideViewPage]()
                    self.reusablePages[pageIdentifier] = pages
                    return pages
                    }()
                pages.append(page)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    page.removeFromSuperview()
                })
                return false
            }
            return true
        }
    }
    
    func didScrollToPageAtIndex(index: Int) {
        let delegate = self.delegate as? PRSlideViewDelegate
        if delegate?.respondsToSelector(#selector(PRSlideViewDelegate.slideView(_:didScrollToPageAtIndex:))) != nil {
            delegate?.slideView!(self, didScrollToPageAtIndex: self.indexForActualIndex(index))
        }
        let offset: Int = index == 0 ? 1 : 0
        let currentRange: NSRange = NSMakeRange(index + offset - 1, 3 - offset)
        self.removePagesOutOfIndexRange(currentRange)
        self.addPagesOfIndexRange(currentRange)
    }
    
    // MARK: Index
    
    func actualIndexForIndex(index: Int, forward: Bool) -> Int {
        if !self.infiniteScrollingEnabled {
            return index
        }
        let currentPageActualIndex: Int = self.currentPageActualIndex
        let currentPageIndex: Int = self.currentPageIndex
        let numberOfPages: Int = self.numberOfPages
        let offset: Int = index - currentPageIndex
        if forward {
            if offset >= 0 {
                return currentPageActualIndex + offset
            } else {
                return currentPageActualIndex + numberOfPages + offset
            }
        } else {
            if offset <= 0 {
                return currentPageActualIndex + offset
            } else {
                return currentPageActualIndex - numberOfPages + offset
            }
        }
    }
    
    func indexForActualIndex(actualIndex: Int) -> Int {
        let numberOfPages: Int = self.numberOfPages
        if self.infiniteScrollingEnabled && actualIndex != 0 {
            var index: Int = actualIndex % numberOfPages
            if index < 0 {
                index += numberOfPages
            }
            return index
        }
        return actualIndex
    }
    
    // MARK: Frame
    
    func rectForPageAtIndex(index: Int) -> CGRect {
        let scrollDirection: PRSlideViewScrollDirection = self.scrollDirection
        let bounds: CGRect = self.bounds
        let width: CGFloat = CGRectGetWidth(bounds)
        let height: CGFloat = CGRectGetHeight(bounds)
        return CGRect(
            x: (scrollDirection == PRSlideViewScrollDirection.Horizontal ? width * CGFloat(index) : 0),
            y: (scrollDirection == PRSlideViewScrollDirection.Vertical ? height * CGFloat(index) : 0),
            width: width,
            height: height
        )
    }
    
    func resizeContent() {
        let scrollDirection: PRSlideViewScrollDirection = self.scrollDirection
        let infiniteScrollingEnabled: Bool = self.infiniteScrollingEnabled
        let numberOfPages: Int = self.numberOfPages
        let bounds: CGRect = self.bounds
        let width: CGFloat = CGRectGetWidth(bounds)
        let height: CGFloat = CGRectGetHeight(bounds)
        let contentSize: CGSize = CGSize(
            width: scrollDirection == PRSlideViewScrollDirection.Horizontal ? infiniteScrollingEnabled ? width * CGFloat(numberOfPages) * CGFloat(kPRSlideViewBufferLength) : width * CGFloat(numberOfPages): width,
            height: scrollDirection == PRSlideViewScrollDirection.Vertical ? infiniteScrollingEnabled ? height * CGFloat(numberOfPages) * CGFloat(kPRSlideViewBufferLength) : height * CGFloat(numberOfPages): height
        )
        self.contentSize = contentSize
        for page: PRSlideViewPage in self.loadedPages {
            page.frame = self.rectForPageAtIndex(page.pageIndex!)
        }
    }
    
    // MARK: Actions
    
    func pageClicked(page: PRSlideViewPage) {
        let delegate = self.delegate as? PRSlideViewDelegate
        if delegate?.respondsToSelector(#selector(PRSlideViewDelegate.slideView(_:didClickPageAtIndex:))) != nil {
            delegate?.slideView!(self, didClickPageAtIndex: self.indexForActualIndex(page.pageIndex!))
        }
    }
    
    // MARK: Init
    
    func setup() {
        self.pagingEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.clipsToBounds = false
        self.scrollsToTop = false
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
