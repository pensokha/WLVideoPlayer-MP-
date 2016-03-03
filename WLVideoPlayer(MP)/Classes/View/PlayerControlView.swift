//
//  PlayerControlView.swift
//  网易新闻
//
//  Created by wl on 16/2/23.
//  Copyright © 2016年 wl. All rights reserved.
//

import UIKit

//protocol WLPlayerControlViewDelegate: class {
//    func didClikOnPlayerControlView(playerControlView: PlayerControlView)
//    func playerControlView(playerControlView: PlayerControlView, pauseBtnDidClik pauseBtn: UIButton)
//    func playerControlView(playerControlView: PlayerControlView, enterFullScreenBtnDidClik enterFullScreenBtn: UIButton)
//
//}

class PlayerControlView: WLBasePlayerControlView {
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var topView: UIImageView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var enterFullBtn: UIButton!
    @IBOutlet weak var pauseBtn: UIButton!
    
    
    @IBOutlet weak var currentSliderConstraint: NSLayoutConstraint!
    @IBOutlet weak var playableSliderConstraint: NSLayoutConstraint!
    
    /// 顶部视图与父视图的宽度约束，默认是等于父视图
    @IBOutlet weak var topViewWidthConstraint: NSLayoutConstraint!
    /// 底部视图与父视图的宽度约束，默认是等于父视图
    @IBOutlet weak var bottomViewWidthConstraint: NSLayoutConstraint!
    /// 底部视图的底部与父视图底部的距离约束，默认是等于0，即紧靠父视图
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        let pan = UIPanGestureRecognizer(target: self, action: Selector("onSliderPan:"))
        sliderView.addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("tap"))
        self.addGestureRecognizer(tap)
    }
    
    // MARK: - 监听方法
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    }
    
    func tap() {
        self.delegate?.didClikOnPlayerControlView?(self)
    }
    
    /**
     当暂停/播放按钮被点击的时候调用
     通知代理处理相关事件
     */
    @IBAction func pauseBtnClik(sender: UIButton) {
        self.delegate?.playerControlView?(self, pauseBtnDidClik: sender)
    }
    /**
     当进入/退出全屏按钮被点击的时候调用
     通知代理处理相关事件
     */
    @IBAction func enterFullScreenBtnClik(sender: UIButton) {
        self.delegate?.playerControlView?(self, enterFullScreenBtnDidClik: sender)
    }
    /**
     自定义控制面板应该实现这个方法，
     实现此方法，将会自动更新面板上显示内容:时间、进度条等
     - parameter currentPlaybackTime: 当前时间
     - parameter duration:            视频总时长
     - parameter playableDuration:    已经缓冲的时长
     */
    override func updateProgress(currentPlaybackTime: NSTimeInterval, duration: NSTimeInterval, playableDuration: NSTimeInterval) {
        
        updateSliderViewWhenPlaying(currentPlaybackTime, duration: duration, playableDuration: playableDuration) { (finishPercent, playablePercent) -> Void in
            
            self.currentSliderConstraint.constant = finishPercent * self.sliderView.bounds.size.width
            self.playableSliderConstraint.constant = playablePercent * self.sliderView.bounds.size.width
            
        }
        timeLabel.text = timeText
    }
    
    /**
     滑动手势的回调方法，在滑动进度条的时候调用
     用来设置新的播放进度(时间)
     */
    func onSliderPan(sender: UIPanGestureRecognizer) {
        
        updateSliderViewWhenSlide(sliderView, sender: sender) { (point) -> Void in
            self.currentSliderConstraint.constant += point.x
            if self.currentSliderConstraint.constant < 0 {
                self.currentSliderConstraint.constant = 0
            }else if self.currentSliderConstraint.constant > self.sliderView.bounds.width {
                self.currentSliderConstraint.constant = self.sliderView.bounds.width
            }
        }
        let finishPercent = NSTimeInterval(currentSliderConstraint.constant / sliderView.bounds.width)
        currentTime = finishPercent * totalDuration
        timeLabel.text = timeText
    }
    /**
     每次播放器的播放模式发生变化的生活调用(进入\退出全屏\旋转等)
     用来更新视图上的约束
     */
    override func relayoutSubView() {
        var temp:CGFloat = 0
        
        let orientation = UIDevice.currentDevice().orientation
        
        if orientation == .LandscapeLeft || orientation == .LandscapeRight {
            temp = self.frame.width - self.frame.height
        }
        
        topViewWidthConstraint.constant = temp
        bottomViewWidthConstraint.constant = temp
        bottomViewBottomConstraint.constant = -temp
        self.layoutSubviews()
        
    }
    
    override func getEnterFullscreenBtn() -> UIButton? {
        return enterFullBtn
    }
}
