//
// The MIT License
//
// Copyright (c) yin.yan, yanyin1986@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation
import UIKit

public protocol InfiniteLoopScrollViewItem {
    var identifier: String { get }
    func requestImage(_ completion: (UIImage?) -> Void)
}

public protocol InfiniteLoopScrollViewDelegate: class {

    func infiniteLoopScrollView(_ scrollView: InfiniteLoopScrollView, didSelectedItem item: InfiniteLoopScrollViewItem, atIndex index: Int)
}

open class InfiniteLoopScrollView: UIView {
    /// time interval for scroll
    public var autoScrollTimeInterval: TimeInterval = 2.0
    /// is auto scroll
    public var autoScroll: Bool = true
    /// infinite loop
    public var infiniteLoop: Bool = true

    public weak var delegate: InfiniteLoopScrollViewDelegate?

    public var items: [InfiniteLoopScrollViewItem] = [] {
        didSet {
            innerItems.removeAll()
            if items.count == 0 {
                // do nothing
            } else if items.count == 1, let first = items.first {
                innerItems.append(first)
            } else if let last = items.last,
                let first = items.first {
                innerItems.append(last)
                innerItems.append(contentsOf: items)
                innerItems.append(first)
            }

            collectionView.reloadData()
        }
    }

    private var innerItems: [InfiniteLoopScrollViewItem] = []
    private var timer: Timer?
    private let collectionId = "_cycleCollectionViewCell"

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: collectionFlowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(InfiniteLoopCollectionViewCell.self, forCellWithReuseIdentifier: collectionId)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.scrollsToTop = false
        return collectionView
    }()

    private lazy var collectionFlowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        return flowLayout
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        debugPrint("deinit")
        invalidateTimer()
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func commonInit() {
        self.addSubview(collectionView)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if collectionFlowLayout.itemSize != bounds.size {
            collectionFlowLayout.itemSize = bounds.size
        }
        if collectionView.frame != self.bounds {
            collectionView.frame = self.bounds
        }
        if collectionView.contentOffset.x == 0, innerItems.count > 1 {
            collectionView.scrollToItem(at: IndexPath(row: 1, section: 0), at: .centeredHorizontally, animated: false)
        }
    }

    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            invalidateTimer()
        } else {
            scheculeTimer()
        }
    }
}

// MARK: - Timer
private extension InfiniteLoopScrollView {
    func invalidateTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
    }

    func scheculeTimer() {
        guard timer == nil, autoScroll, autoScrollTimeInterval > 0, items.count > 1 else { return }
        timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(scrollToNextPage(_:)), userInfo: nil, repeats: true)
    }

    @objc func scrollToNextPage(_ timer: Timer) {
        let index = Int(self.collectionView.contentOffset.x / self.collectionView.bounds.width)
        let nextIndexPath = IndexPath(row: index + 1, section: 0)
        self.collectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension InfiniteLoopScrollView: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return innerItems.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionId, for: indexPath) as? InfiniteLoopCollectionViewCell else {
            fatalError("initialize cell failed")
        }
        let item = items[(indexPath.row + items.count - 1) % items.count]
        cell.identifier = item.identifier
        item.requestImage { (image) in
            if cell.identifier == item.identifier {
                cell.imageView.image = image
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout && UIScrollViewDelegate
extension InfiniteLoopScrollView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = innerItems[indexPath.row]
        guard let index = innerItems.firstIndex(where: { $0.identifier == item.identifier }) else {
            return
        }
        delegate?.infiniteLoopScrollView(self, didSelectedItem: item, atIndex: index)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        invalidateTimer()
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / scrollView.bounds.width)
        if index == 0 {
            debugPrint(scrollView.contentOffset.x)
            let width = scrollView.bounds.width
            let targetX = CGFloat(innerItems.count - 2) * width
            let diffX = scrollView.contentOffset.x
            scrollView.setContentOffset(CGPoint(x: targetX + diffX, y: 0), animated: false)
            targetContentOffset.pointee.x = targetX
        } else if index == items.count + 1 {
            debugPrint(" -- \(scrollView.contentOffset.x)")
            let width = scrollView.bounds.width
            let targetX = width
            let diffX = scrollView.contentOffset.x - width * CGFloat(index)
            scrollView.setContentOffset(CGPoint(x: targetX + diffX, y: 0), animated: false)
            targetContentOffset.pointee.x = targetX
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard innerItems.count > 1 else { return }

        let index = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if index == innerItems.count - 1 {
            let indexPath = IndexPath(row: 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scheculeTimer()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scheculeTimer()
    }
}
