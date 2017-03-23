//
//  PlayerVideoViewController.swift
//  PlayerVideo
//
//  Created by David Alejandro on 2/17/16.
//  Copyright © 2016 David Alejandro. All rights reserved.
//

import UIKit
import AVFoundation.AVPlayer

private extension Selector {
    static let playerItemDidPlayToEndTime = #selector(PlayerView.playerItemDidPlayToEndTime(_:))
}

public extension PVTimeRange{
    static let zero = kCMTimeRangeZero
}

public typealias PVStatus = AVPlayerStatus
public typealias PVItemStatus = AVPlayerItemStatus
public typealias PVTimeRange = CMTimeRange
public typealias PVPlayer = AVQueuePlayer
public typealias PVPlayerItem = AVPlayerItem

public protocol PlayerViewDelegate: class {
    func playerVideo(_ player: PlayerView, statusPlayer: PVStatus, error: NSError?)
    func playerVideo(_ player: PlayerView, statusItemPlayer: PVItemStatus, error: NSError?)
    func playerVideo(_ player: PlayerView, loadedTimeRanges: [PVTimeRange])
    func playerVideo(_ player: PlayerView, duration: Double)
    func playerVideo(_ player: PlayerView, currentTime: Double)
    func playerVideo(_ player: PlayerView, rate: Float)
    func playerVideo(playerFinished player: PlayerView)
}

public extension PlayerViewDelegate {
    
    func playerVideo(_ player: PlayerView, statusPlayer: PVStatus, error: NSError?) {
        
    }
    func playerVideo(_ player: PlayerView, statusItemPlayer: PVItemStatus, error: NSError?) {
        
    }
    func playerVideo(_ player: PlayerView, loadedTimeRanges: [PVTimeRange]) {
        
    }
    func playerVideo(_ player: PlayerView, duration: Double) {
        
    }
    func playerVideo(_ player: PlayerView, currentTime: Double) {
        
    }
    func playerVideo(_ player: PlayerView, rate: Float) {
        
    }
    func playerVideo(playerFinished player: PlayerView) {
        
    }
}

public enum PlayerViewFillMode {
    case resizeAspect
    case resizeAspectFill
    case resize
    
    init?(videoGravity: String){
        switch videoGravity {
        case AVLayerVideoGravityResizeAspect:
            self = .resizeAspect
        case AVLayerVideoGravityResizeAspectFill:
            self = .resizeAspectFill
        case AVLayerVideoGravityResize:
            self = .resize
        default:
            return nil
        }
    }
    
    var AVLayerVideoGravity:String {
        get {
            switch self {
            case .resizeAspect:
                return AVLayerVideoGravityResizeAspect
            case .resizeAspectFill:
                return AVLayerVideoGravityResizeAspectFill
            case .resize:
                return AVLayerVideoGravityResize
            }
        }
    }
}

private extension CMTime {
    static var zero:CMTime { return kCMTimeZero }
}
/// A simple `UIView` subclass that is backed by an `AVPlayerLayer` layer.
@objc open class PlayerView: UIView {
    
    
    
    fileprivate var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    fileprivate var timeObserverToken: AnyObject?
    fileprivate weak var lastPlayerTimeObserve: PVPlayer?
    
    fileprivate var urlsQueue: [URL]?
    //MARK: - Public Variables
    open weak var delegate: PlayerViewDelegate?
    
    open var loopVideosQueue = false
    open var player: PVPlayer? {
        get {
            return playerLayer.player as? PVPlayer
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    
    open var fillMode: PlayerViewFillMode! {
        didSet {
            playerLayer.videoGravity = fillMode.AVLayerVideoGravity
        }
    }
    
    
    open var currentTime: Double {
        get {
            guard let player = player else {
                return 0
            }
            return CMTimeGetSeconds(player.currentTime())
        }
        set {
            guard let timescale = player?.currentItem?.duration.timescale else {
                return
            }
            let newTime = CMTimeMakeWithSeconds(newValue, timescale)
            player!.seek(to: newTime,toleranceBefore: CMTime.zero,toleranceAfter: CMTime.zero)
        }
    }
    open var interval = CMTimeMake(1, 60) {
        didSet {
            if rate != 0 {
                addCurrentTimeObserver()
            }
        }
    }
    
    open var rate: Float {
        get {
            guard let player = player else {
                return 0
            }
            return player.rate
        }
        set {
            if newValue == 0 {
                removeCurrentTimeObserver()
            } else if rate == 0 && newValue != 0 {
                addCurrentTimeObserver()
            }
            
            player?.rate = newValue
        }
    }
    // MARK: private Functions
    
    
    /**
     Add all observers for a PVPlayer
     */
    func addObserversPlayer(_ avPlayer: PVPlayer) {
        avPlayer.addObserver(self, forKeyPath: "status", options: [.new], context: &statusContext)
        avPlayer.addObserver(self, forKeyPath: "rate", options: [.new], context: &rateContext)
        avPlayer.addObserver(self, forKeyPath: "currentItem", options: [.old,.new], context: &playerItemContext)
    }
    
    /**
     Remove all observers for a PVPlayer
     */
    func removeObserversPlayer(_ avPlayer: PVPlayer) {
        
        avPlayer.removeObserver(self, forKeyPath: "status", context: &statusContext)
        avPlayer.removeObserver(self, forKeyPath: "rate", context: &rateContext)
        avPlayer.removeObserver(self, forKeyPath: "currentItem", context: &playerItemContext)
        
        if let timeObserverToken = timeObserverToken {
            avPlayer.removeTimeObserver(timeObserverToken)
        }
    }
    func addObserversVideoItem(_ playerItem: PVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [], context: &loadedContext)
        playerItem.addObserver(self, forKeyPath: "duration", options: [], context: &durationContext)
        playerItem.addObserver(self, forKeyPath: "status", options: [], context: &statusItemContext)
        NotificationCenter.default.addObserver(self, selector: .playerItemDidPlayToEndTime, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    func removeObserversVideoItem(_ playerItem: PVPlayerItem) {
        
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges", context: &loadedContext)
        playerItem.removeObserver(self, forKeyPath: "duration", context: &durationContext)
        playerItem.removeObserver(self, forKeyPath: "status", context: &statusItemContext)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func removeCurrentTimeObserver() {
        
        if let timeObserverToken = self.timeObserverToken {
            lastPlayerTimeObserve?.removeTimeObserver(timeObserverToken)
        }
        timeObserverToken = nil
    }
    
    func addCurrentTimeObserver() {
        removeCurrentTimeObserver()
        
        lastPlayerTimeObserve = player
        self.timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time-> Void in
            if let mySelf = self {
                self?.delegate?.playerVideo(mySelf, currentTime: mySelf.currentTime)
            }
        } as AnyObject?
    }
    
    func playerItemDidPlayToEndTime(_ aNotification: Notification) {
        //notification of player to stop
        let item = aNotification.object as! PVPlayerItem
        print("Itens \(player?.items().count)")
        if loopVideosQueue && player?.items().count == 1,
            let urlsQueue = urlsQueue {
            
            self.addVideosOnQueue(urls: urlsQueue, afterItem: item)
        }
        
        self.delegate?.playerVideo(playerFinished: self)
    }
    // MARK: public Functions
    
    open func play() {
        rate = 1
        //player?.play()
    }
    
    open func pause() {
        rate = 0
        //player?.pause()
    }
    
    
    open func stop() {
        currentTime = 0
        pause()
    }
    open func next() {
        player?.advanceToNextItem()
    }
    
    open func resetPlayer() {
        urlsQueue = nil
        guard let player = player else {
            return
        }
        player.pause()
        
        removeObserversPlayer(player)
        
        if let playerItem = player.currentItem {
            removeObserversVideoItem(playerItem)
        }
        self.player = nil
    }
    
    open func availableDuration() -> PVTimeRange {
        let range = self.player?.currentItem?.loadedTimeRanges.first
        if let range = range {
            return range.timeRangeValue
        }
        return PVTimeRange.zero
    }
    
    open func screenshot() throws -> UIImage? {
        guard let time = player?.currentItem?.currentTime() else {
            return nil
        }
        
        return try screenshotCMTime(time)?.0
    }
    
    open func screenshotTime(_ time: Double? = nil) throws -> (UIImage, photoTime: CMTime)?{
        guard let timescale = player?.currentItem?.duration.timescale else {
            return nil
        }
        
        let timeToPicture: CMTime
        if let time = time {
            
            timeToPicture = CMTimeMakeWithSeconds(time, timescale)
        } else if let time = player?.currentItem?.currentTime() {
            timeToPicture = time
        } else {
            return nil
        }
        return try screenshotCMTime(timeToPicture)
    }
    
    fileprivate func screenshotCMTime(_ cmTime: CMTime) throws -> (UIImage,photoTime: CMTime)? {
        guard let player = player , let asset = player.currentItem?.asset else {
            return nil
        }
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        var timePicture = CMTime.zero
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        
        let ref = try imageGenerator.copyCGImage(at: cmTime, actualTime: &timePicture)
        let viewImage: UIImage = UIImage(cgImage: ref)
        return (viewImage, timePicture)
    }
    open var url: URL? {
        didSet {
            guard let url = url else {
                urls = nil
                return
            }
            urls = [url]
        }
    }
    
    open var urls: [URL]? {
        willSet(newUrls) {
            
            resetPlayer()
            guard let urls = newUrls else {
                return
            }
            //reset before put another URL
            
            urlsQueue = urls
            let playerItems = urls.map { (url) -> PVPlayerItem in
                return PVPlayerItem(url: url)
            }
            
            let avPlayer = PVPlayer(items: playerItems)
            self.player = avPlayer
            
            avPlayer.actionAtItemEnd = .pause
            
            
            let playerItem = avPlayer.currentItem!
            
            addObserversPlayer(avPlayer)
            addObserversVideoItem(playerItem)
            
            // Do any additional setup after loading the view, typically from a nib.
        }
    }
    open func addVideosOnQueue(urls: [URL], afterItem: PVPlayerItem? = nil) {
        //on last item on player
        let item = afterItem ?? player?.items().last
        
        urlsQueue?.append(contentsOf: urls)
        //for each url found
        urls.forEach({ (url) in
            
            //create a video item
            let itemNew = PVPlayerItem(url: url)
            
            //and insert the item on the player
            player?.insert(itemNew, after: item)
        })
        
    }
    open func addVideosOnQueue(_ urls: URL..., afterItem: PVPlayerItem? = nil) {
        return addVideosOnQueue(urls: urls,afterItem: afterItem)
    }
    // MARK: public object lifecycle view
    
    override open class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
        
        self.fillMode = .resizeAspect
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.fillMode = .resizeAspect
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.fillMode = .resizeAspect
    }
    
    deinit {
        delegate = nil
        resetPlayer()
    }
    // MARK: private variables for context KVO
    
    fileprivate var statusContext = true
    fileprivate var statusItemContext = true
    fileprivate var loadedContext = true
    fileprivate var durationContext = true
    fileprivate var currentTimeContext = true
    fileprivate var rateContext = true
    fileprivate var playerItemContext = true
    
    
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //print("CHANGE",keyPath)
        
        
        if context == &statusContext {
            
            guard let avPlayer = player else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            self.delegate?.playerVideo(self, statusPlayer: avPlayer.status, error: avPlayer.error as NSError?)
            
            
        } else if context == &loadedContext {
            
            let playerItem = player?.currentItem
            
            guard let times = playerItem?.loadedTimeRanges else {
                return
            }
            
            let values = times.map({ $0.timeRangeValue})
            self.delegate?.playerVideo(self, loadedTimeRanges: values)
            
            
        } else if context == &durationContext{
            
            if let currentItem = player?.currentItem {
                self.delegate?.playerVideo(self, duration: currentItem.duration.seconds)
                
            }
            
        } else if context == &statusItemContext{
            //status of item has changed
            if let currentItem = player?.currentItem {
                
                self.delegate?.playerVideo(self, statusItemPlayer: currentItem.status, error: currentItem.error as NSError?)
            }
            
        } else if context == &rateContext{
            guard let newRateNumber = (change?[NSKeyValueChangeKey.newKey] as? NSNumber) else{
                return
            }
            let newRate = newRateNumber.floatValue
            if newRate == 0 {
                removeCurrentTimeObserver()
            } else {
                addCurrentTimeObserver()
            }
            
            self.delegate?.playerVideo(self, rate: newRate)
            
        } else if context == &playerItemContext{
            guard let oldItem = (change?[NSKeyValueChangeKey.oldKey] as? PVPlayerItem) else{
                return
            }
            removeObserversVideoItem(oldItem)
            guard let newItem = (change?[NSKeyValueChangeKey.newKey] as? PVPlayerItem) else{
                return
            }
            addObserversVideoItem(newItem)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
