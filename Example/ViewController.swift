//
//  ViewController.swift
//  Example
//
//  Created by yin.yan on 2018/12/07.
//  Copyright © 2018 Leon.yan. All rights reserved.
//

import UIKit
import InfiniteLoopScrollView

struct Item: InfiniteLoopScrollViewItem {
    var identifier: String
    var image: UIImage

    func requestImage(_ completion: (UIImage?) -> Void) {
        completion(image)
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: InfiniteLoopScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let items: [Item] = [
            Item(identifier: "thumb_filter_adore", image: UIImage(named: "thumb_filter_adore")!),
            Item(identifier: "thumb_filter_alice", image: UIImage(named: "thumb_filter_alice")!),
            Item(identifier: "thumb_filter_blues", image: UIImage(named: "thumb_filter_blues")!),
            Item(identifier: "thumb_filter_calm", image: UIImage(named: "thumb_filter_calm")!),
            Item(identifier: "thumb_filter_classic", image: UIImage(named: "thumb_filter_classic")!),
            Item(identifier: "thumb_filter_time", image: UIImage(named: "thumb_filter_time")!),
        ]
        scrollView.items = items
        scrollView.delegate = self
    }
}

extension ViewController: InfiniteLoopScrollViewDelegate {
    
    func infiniteLoopScrollView(_ scrollView: InfiniteLoopScrollView, didSelectedItem item: InfiniteLoopScrollViewItem, atIndex index: Int) {

    }
}
