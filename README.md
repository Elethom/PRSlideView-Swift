# PRSlideView-Swift

This is the Swift language version of [PRSlideView](https://github.com/Elethom/PRSlideView).

## General

Slide view with gracefully written UIKit-like methods, delegate and data source protocol. Infinite scrolling supported.

Note: Auto layout not supported due to the special behaviours of `UIScrollView`. Please use autoresizing mask instead or wrap it with a container view.

## Usage

### Configure a Slide View

```Swift
slideView.delegate = self
slideView.dataSource = self
slideView.scrollDirection = .Vertical
slideView.infiniteScrollingEnabled = true
slideView.registerClass(
    PRAlbumPage.self,
    identifier: PRAlbumPage.description()
)
```

### Create a Slide View Page Subclass

```Swift
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
```

### Use Data Source

```Swift
// MARK: PRSlideViewDataSource

func numberOfPagesInSlideView(slideView: PRSlideView) -> Int {
    return self.albumData.count
}

func slideView(slideView: PRSlideView, pageAtIndex index: Int) -> PRSlideViewPage {
    let page: PRAlbumPage = slideView.dequeueReusablePageWithIdentifier(PRAlbumPage.description(), index: index) as PRAlbumPage
    
    let imageName: String = self.albumData[index].stringByAppendingPathExtension("jpg")!
    page.coverImageView.image = UIImage(named: imageName)
    
    return page
}
```

### Use Delegate

```Swift
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
```

All done! You can check out the code in the demo provided.

## License

This code is distributed under the terms and conditions of the [MIT license](http://opensource.org/licenses/MIT).

## Donate

You can support me by:

* sending me iTunes Gift Cards;
* via [Alipay](https://www.alipay.com): elethomhunter@gmail.com
* via [PayPal](https://www.paypal.com): elethomhunter@gmail.com

:-)

## Contact

* [Telegram](https://telegram.org): @elethom
* [Email](mailto:elethomhunter@gmail.com)
* [Twitter](https://twitter.com/elethomhunter)
* [Blog](http://blog.projectrhinestone.org)

