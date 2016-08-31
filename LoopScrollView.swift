//
//  LoopScrollView.swift
//  HideSeek
//  无限轮播视图＋自动播放
//  Created by qing on 16/8/31.
//  Copyright © 2016年 juxinli. All rights reserved.
//

import UIKit

class LoopScrollView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    ///
    /// 图片cell
    ///
    private class Cell: UICollectionViewCell {
        ///
        /// 图片
        ///
        var imageView: UIImageView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.clipsToBounds = true
            imageView.contentMode = .ScaleAspectFill
            self.contentView.addSubview(imageView)
            
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: .DirectionLeftToRight, metrics: nil, views: ["imageView": imageView]))
            self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: .DirectionLeftToRight, metrics: nil, views: ["imageView": imageView]))
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    private let pageCount = 1000
    private var waterFlow: UICollectionView!
    private var pageControl: UIPageControl!
    /// 计时器
    private var timer: NSTimer?
    /// 数据源
    private var photos: [AnyObject] = []
    /// 数据源是否是nsurl
    private var isPhotoUrl = false
    /// 是始打开计时器，默认关闭
    var isOpenTimer = false
    /// 点击每一项回调
    var didClickItemClosure: ((index: Int) -> Void)?
    
    deinit {
        print(">>>>>>>>>>LoopScrollView deinit")
        if isOpenTimer {
            removeTimer()
        }
        if self.didClickItemClosure != nil {
            self.didClickItemClosure = nil
        }
        
        self.photos.removeAll()
    }

    init(photos: [AnyObject]) {
        super.init(frame: CGRectZero)
        self.photos.appendContentsOf(photos)
        if self.photos.count > 0 {
            if self.photos[0].isKindOfClass(NSURL.self) {
                isPhotoUrl = true
            }
        }
        initViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///
    /// 初始化视图
    ///
    private func initViews() {
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .Horizontal
        
        waterFlow = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        waterFlow.translatesAutoresizingMaskIntoConstraints = false
        waterFlow.pagingEnabled = true
        waterFlow.dataSource = self
        waterFlow.delegate = self
        waterFlow.showsHorizontalScrollIndicator = false
        waterFlow.showsVerticalScrollIndicator = false
        self.addSubview(waterFlow)
        
        waterFlow.registerClass(Cell.self, forCellWithReuseIdentifier: "kCell")
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[waterFlow]|", options: .DirectionLeftToRight, metrics: nil, views: ["waterFlow": waterFlow]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[waterFlow]|", options: .DirectionLeftToRight, metrics: nil, views: ["waterFlow": waterFlow]))
        
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = self.photos.count
        self.addSubview(pageControl)
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pageControl(15)]|", options: .DirectionLeftToRight, metrics: nil, views: ["pageControl": pageControl]))
        self.addConstraint(NSLayoutConstraint(item: pageControl, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        waterFlow.scrollToItemAtIndexPath(NSIndexPath(forItem: (self.photos.count * pageCount) / 2, inSection: 0), atScrollPosition: .Left, animated: false)
        
        if isOpenTimer {
            addTimer()
        }
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        if isOpenTimer {
            if newSuperview == nil {
                removeTimer()
            }
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count * pageCount
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("kCell", forIndexPath: indexPath) as! Cell
        
        let index = indexPath.row % self.photos.count
        
        if isPhotoUrl {
            let url = self.photos[index] as! NSURL
            cell.imageView.sd_setImageWithURL(url)
        }
        else {
            let named = self.photos[index] as! String
            cell.imageView.image = UIImage(named: named)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row % self.photos.count
        if let closure = self.didClickItemClosure {
            closure(index: index)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    private func addTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(timerHandler), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(self.timer!, forMode:NSRunLoopCommonModes)
    }
    
    @objc private func timerHandler() {
        let currentIndexPath = waterFlow.indexPathsForVisibleItems().last
        if let indexPath = currentIndexPath {
            let nextItem = indexPath.item + 1
            
            waterFlow.scrollToItemAtIndexPath(NSIndexPath(forItem: nextItem, inSection: 0), atScrollPosition: .Left, animated: true)
        }
    }
    
    private func removeTimer() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x / scrollView.frame.size.width + 0.5)) % self.photos.count
        pageControl.currentPage = page
        
//        let pageWidth = CGRectGetWidth(scrollView.bounds)
//        let currentPage = Int(floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if isOpenTimer {
            removeTimer()
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isOpenTimer {
            addTimer()
        }
    }
}
