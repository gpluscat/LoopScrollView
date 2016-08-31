# LoopScrollView
无限轮播视图＋自动播放

let loopView = LoopScrollView(photos: ["home_banner", "home_banner", "home_banner"])
loopView.translatesAutoresizingMaskIntoConstraints = false
loopView.isOpenTimer = true
headerView.addSubview(loopView)

headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[loopView]|", options: .DirectionLeftToRight, metrics: nil, views: ["loopView": loopView]))
headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[loopView]|", options: .DirectionLeftToRight, metrics: nil, views: ["loopView": loopView]))

loopView.didClickItemClosure = { (index: Int) in
print(">>>>>>>>>>index \(index)")
}
