//
//  PlayerVC.swift
//  FunBox
//
//  Created by AdBox on 4/27/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage

class PlayerVC: UIViewController {
    
    var videos          : [Video]?
    var player          : AVPlayer?
    var playerLayer     : AVPlayerLayer?
    var selectedIndex   : Int!
    
    var isVideoPlaying      = false
    var isDisplayData       = false
    var isAutoPlay          = false
    var isFullScreen        = false
    var isControllerHidden  = false
    var isBuffering         = false
    
    open var delayItem  : DispatchWorkItem?
    open var animateDelayTimeInterval = TimeInterval(5)
    
    /******************************************************************/
    // MARK: - IBOutlet
    /******************************************************************/
    
    @IBOutlet weak var lb_noInternet: UILabel!
    @IBOutlet weak var iv_noInternet: UIImageView!
    @IBOutlet weak var indicator_loadingContent: UIActivityIndicatorView!
    @IBOutlet weak var view_noInternet: UIView!
    @IBOutlet weak var btn_retry: UIButton!
    @IBOutlet weak var btn_replay: UIButton!
    @IBOutlet weak var view_videoPlayer: UIView!
    @IBOutlet weak var playerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var view_controller: UIView!
    @IBOutlet weak var btn_dismissPlayer: UIButton!
    @IBOutlet weak var lb_videoTitle: UILabel!
    @IBOutlet weak var lb_totalDuration: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lb_currentDuration: UILabel!
    @IBOutlet weak var btn_previous: UIButton!
    @IBOutlet weak var btn_playPause: UIButton!
    @IBOutlet weak var indicator_player: UIActivityIndicatorView!
    @IBOutlet weak var btn_fullScreen: UIButton!
    @IBOutlet weak var btn_autoPlay: UIButton!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    /******************************************************************/
    // MARK: - Override Func
    /******************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.orientation.isLandscape {
  
            /* Getting wrong frame size when play video from landscape mode.
             * So here i alter the frame size. This is not right way i know,
             * but need time to find out the reason.
             */
            let frame = UIScreen.main.bounds
            self.view.frame = CGRect(x: 0, y: 0, width: frame.height, height: frame.width)
            isFullScreen = true
            btn_fullScreen.setImage(UIImage(named: "ic_minPlayer"), for: .normal)
            UIApplication.shared.isStatusBarHidden = true
        }

        // Add 9:16 ratio height for video player
        let height = (self.view.frame.width) * 9 / 16
        // initial video player frame protrait
        playerViewHeight.constant = height
        view_videoPlayer.layoutIfNeeded()
        view_controller.layoutIfNeeded()
        
        btn_retry.layer.cornerRadius = 5
        btn_retry.layer.borderWidth = 1
        
        
        // Change video player thumb
        slider.setThumbImage(UIImage(named: "thumb"), for: UIControlState())
        
        btn_autoPlay.layer.borderWidth = 1
        btn_autoPlay.layer.borderColor = UIColor.white.cgColor
        btn_autoPlay.layer.cornerRadius = 5
       
        addTapGestureOnPlayerView()
        showLoading()
        intializeContent()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Notification for when app becomes active
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidBecomeActive),
                                               name: Notification.Name("UIApplicationDidBecomeActiveNotification"),
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        videos?.removeAll()
        NotificationCenter.default.removeObserver(self)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            isFullScreen = true
            btn_fullScreen.setImage(UIImage(named: "ic_minPlayer"), for: .normal)
        } else {
            isFullScreen = false
            btn_fullScreen.setImage(UIImage(named: "ic_maxPlayer"), for: .normal)
        }
        changePlayerSize(to: size)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //this is when the player is ready and rendering frames
        if keyPath == "currentItem.loadedTimeRanges" {
            
            hideLoading()
        
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                
                if seconds.isNaN || seconds.isInfinite {
                    return
                }
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                self.lb_totalDuration.text = "\(minutesText):\(secondsText)"
            }
            // Displaying buffer progress
            getStreamingProgress()
        }
        else if keyPath == "currentItem.playbackBufferEmpty" {
            showLoading()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /******************************************************************/
    // MARK: - IBActions
    /******************************************************************/
    
    /***
     * Dismiss player
        - Button animation
        - set protrait orientation
        - Stop player
     */
    @IBAction func dismissPlayer(_ sender: Any) {
        
        Animation.sharedInstance.animate(button: btn_dismissPlayer)
        
        if isFullScreen {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
        stopPlayer()
        self.dismiss(animated: true, completion: nil)
    }

    /***
     * Play next item
        - increase item index by 1
        - Button animation
     */
    @IBAction func playNext(_ sender: Any) {
        
        if  selectedIndex + 1 < (videos?.count)!{
            playNext()
        }
        Animation.sharedInstance.animate(button: btn_next)
    }
    
    /***
     * Play previous item
     - Decrease item index by 1
     - Stop current item
     - show loader view
     - reload tableview
     - Button animation
     */
    @IBAction func playPrevious(_ sender: Any) {
        
        if selectedIndex - 1 >= 0 {
            stopPlayer()
            showLoading()
            selectedIndex = selectedIndex - 1
            tableView.reloadData()
            setupPlayerView()
        }
        Animation.sharedInstance.animate(button: btn_previous)
    }
    
    /***
     * Make player fullscreen
        - Button animation
        - Set device orientation
        - Change player view size
     */
    @IBAction func fullScreen(_ sender: Any) {
        
        Animation.sharedInstance.animate(button: btn_fullScreen)
        
        if isFullScreen {
            isFullScreen = false
            btn_fullScreen.setImage(UIImage(named: "ic_maxPlayer"), for: .normal)
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        } else {
            isFullScreen = true
            btn_fullScreen.setImage(UIImage(named: "ic_minPlayer"), for: .normal)
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        
        // Change the player size after orientation changed
        changePlayerSize(to: CGSize(width: self.view.frame.width, height: self.view.frame.height))
    }
    
    /***
     * Replay current item
        - Button animation
        - Display loading
     */
    @IBAction func replay(_ sender: Any) {
        
        Animation.sharedInstance.animate(button: btn_replay)
        showLoading()
        setupPlayerView()
    }
    
    /***
     * re-try to play if connection failed
     */
    @IBAction func retry(_ sender: Any) {

        self.parseContentData()
    }
    
    /***
     * Set Automatically play next item if available
        - Set auto play T/F
        - Button animation
     */
    @IBAction func willAutoPlay(_ sender: Any) {
        
        if isAutoPlay {
            isAutoPlay = false
            btn_autoPlay.backgroundColor = UIColor.clear
            btn_autoPlay.setTitleColor(UIColor.white, for: UIControlState.normal)
        }
        else {
            isAutoPlay = true
            btn_autoPlay.backgroundColor = UIColor.white
            btn_autoPlay.setTitleColor(UIColor.black, for: UIControlState.normal)
        }
        Animation.sharedInstance.animate(button: btn_autoPlay)
    }
    
    /***
     * Play or pause item
     - Set icon
     - Button animation
     */
    @IBAction func playOrPause(_ sender: Any) {
  
        if isVideoPlaying {
            player?.pause()
            btn_playPause.setImage(UIImage(named: "play"), for: .normal)
            isVideoPlaying = false
        } else {
            player?.play()
            btn_playPause.setImage(UIImage(named: "pause"), for: .normal)
            isVideoPlaying = true
        }
        Animation.sharedInstance.animate(button: btn_playPause)
    }
    
    /***
     * Drug slider
     - Hide replay button
     - Pause auto fade animation
     - Get slider drug value
     - play from that value
     - start auto fade animation
     */
    @IBAction func sliderAction(_ sender: Any) {
        
        // Hide replay button if drug after finished playing
        btn_replay.isHidden = true
        // Not show p/p button when beffering
        if !indicator_player.isAnimating {
            btn_playPause.isHidden = false
        }
        
        if let duration = player?.currentItem?.duration {

            // Cancel auto fade animation during drug on slide
            cancelAutoFadeOutAnimation()
            
            let totalSeconds = CMTimeGetSeconds(duration)
            // Return if value is not a number or infinite
            if totalSeconds.isNaN || totalSeconds.isInfinite {
                return
            }
            
            let value = Double(slider.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)

            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                // Start auto fade animation after finished drug
                self.autoFadeOutControlViewWithAnimation()
            })
        }
    }
    
    /******************************************************************/
    // MARK: - Custom Actions
    /******************************************************************/
    
    /***
     *  Decide play video song or movie/natok
     - If item is video song play directly otherwise parse movie/natok content
     */
    func intializeContent() {
        
        if HomeVC.contentType == "VIDEO" {
            self.setupPlayerView()
            self.isDisplayData = true
        }
        else {
            self.parseContentData()
        }
    }
    
    /***
     *  Call back func to parse content (movie/natok item)
     - request for data
     - After successfully parse replace video array with parse item
     - Play very first item by setting index 0
     - reload table view with parse data
     */
    func parseContentData(){

        let id = videos?[selectedIndex].id
        let parameter : [String:String] = ["album_id": id!]
        
        //Show no internet view with loading
        view_noInternet.isHidden = false
        iv_noInternet.isHidden = true
        lb_noInternet.isHidden = true
        btn_retry.isHidden = true
        indicator_loadingContent.isHidden = false
        indicator_loadingContent.startAnimating()
        
        DataParge.shared.parseAPIData(DSSNatokMovieContentURL, parameters: parameter, type: DSSNatokMovieContent, callback: { (response, status) in
            
            self.indicator_loadingContent.stopAnimating()
            
            if status {
                print("😄😄😄 Parse video song Content Data is successfull 😄😄😄")
                // Hide no internet view if success
                self.view_noInternet.isHidden = true
                
                self.videos = response
                self.selectedIndex = 0
                self.setupPlayerView()
                self.isDisplayData = true
                self.tableView.reloadData()
            }
            else {

                //Show no internet view with Connection Failed
                self.view_noInternet.isHidden = false
                self.indicator_loadingContent.isHidden = true
                self.iv_noInternet.isHidden = false
                self.lb_noInternet.isHidden = false
                self.btn_retry.isHidden = false
            }
        })
    }
    
    /***
     * Tap gesture for player view for show/hide controller
     */
    func addTapGestureOnPlayerView(){
        
        let hideGesture = UITapGestureRecognizer.init(target: self, action: #selector(showHideController))
        hideGesture.numberOfTapsRequired = 1
        view_controller.addGestureRecognizer(hideGesture)
        
        let showGesture = UITapGestureRecognizer.init(target: self, action: #selector(showHideController))
        showGesture.numberOfTapsRequired = 1
        view_videoPlayer.addGestureRecognizer(showGesture)
    }
    
    /***
     * Can rotate device
     - This func called from app delegate
     */
    func canRotate() -> Void {}
    
    /***
     * Show indicator when buffer
     - buffering state is true
     - Hide play button and show indicator
     */
    func showLoading(){
        
        isBuffering = true
        indicator_player.isHidden = false
        indicator_player.startAnimating()
        btn_playPause.isHidden = true
        btn_replay.isHidden = true
    }
    
    /***
     * Hide indicator
     - buffering state is false
     - Show play button and hide indicator
     */
    func hideLoading(){
        
        isBuffering = false
        indicator_player.isHidden = true
        indicator_player.stopAnimating()
        btn_playPause.isHidden = false
    }
    
    /***
     * Update next/ previous button
     - If next/previous item availabe, enable button otherwise disable
     */
    func upadateController() {
    
        if  selectedIndex + 1 < (videos?.count)! {
            btn_next.isEnabled = true
        } else {
            btn_next.isEnabled = false
        }
        
        if  selectedIndex - 1 >= 0 {
            btn_previous.isEnabled = true
        } else {
            btn_previous.isEnabled = false
        }
    }
    
    /***
     * Display the progress of buffer amount
     - Get streaming amount
     - set value on progress view
     */
    func getStreamingProgress(){
        
        if let loadedTimeRanges = self.player?.currentItem?.loadedTimeRanges,
            let first = loadedTimeRanges.first,
            let totalDuration = player?.currentItem?.duration {
            
            let timeRange = first.timeRangeValue
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSecound = CMTimeGetSeconds(timeRange.duration)
            let result = startSeconds + durationSecound
            let totalDurationInSec = CMTimeGetSeconds(totalDuration)
            
            self.progressView.setProgress(Float(result/totalDurationInSec), animated: true)
        }
    }
    
    /***
     * Show/hide controller view by tap on view
     */
    func showHideController(){
        
        controlViewAnimation(isShow: !isControllerHidden)
    }
 
    /**
     * Cancel auto fade out controll view with animtion
     */
    open func cancelAutoFadeOutAnimation() {
        delayItem?.cancel()
    }
    
    /**
     * Auto fade out controll view with animtion
     */
    open func autoFadeOutControlViewWithAnimation() {
        cancelAutoFadeOutAnimation()
        delayItem = DispatchWorkItem { [weak self] in
            self?.controlViewAnimation(isShow: false)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.animateDelayTimeInterval,
                                      execute: delayItem!)
    }
    
    /**
     * Parameter isShow: is to show the controlview
     */
    open func controlViewAnimation(isShow: Bool) {
        let alpha: CGFloat = isShow ? 1.0 : 0.0
        self.isControllerHidden = isShow
      
        UIView.animate(withDuration: 0.3, animations: {
            self.view_controller.alpha    = alpha
        }) { (_) in
            if isShow {
                self.autoFadeOutControlViewWithAnimation()
            }
        }
    }

    /***
     * Player did finished play item
     - Show control view
     - cancel auto fade animation
     */
    func playerDidFinishPlaying() {
        
        // Show player controller
        controlViewAnimation(isShow: true)
        // And cancel the auto hide time
        cancelAutoFadeOutAnimation()
 
        if isAutoPlay {
            if  selectedIndex + 1 < (videos?.count)!{
                // If auto play true and next item available then play
                playNext()
            }
            else {
                /***
                 - If next item not available then hide play/pause button
                 - show replay button
                 - set play button
                 */
                btn_replay.isHidden = false
                isVideoPlaying = false
                btn_playPause.setImage(UIImage(named: "play"), for: UIControlState())
                btn_playPause.isHidden = true
            }
        } else {
            /***
             - If auto play false hide play/pause button
             - show replay button
             - set play button
             */
            btn_replay.isHidden = false
            isVideoPlaying = false
            btn_playPause.setImage(UIImage(named: "play"), for: UIControlState())
            btn_playPause.isHidden = true
        }
    }
    
    /***
     * Play next item
     - Stop current item
     - show loading
     - increase item index by 1
     - reload tableview 
     - play the item
     */
    func playNext(){
        
        stopPlayer()
        showLoading()
        selectedIndex = selectedIndex + 1
        tableView.reloadData()
        setupPlayerView()
    }
    
    /***
     * Video player Orientation change protrait to landscape and vice-versa
     */
    func changePlayerSize(to size: CGSize) {
        
        // Add 9:16 ratio height for video player
        let height = (size.width) * 9 / 16
        // Change video player height after orientation change
        playerViewHeight.constant = height
        view_videoPlayer.layoutIfNeeded()
        // Create video player frame
        let videoPlayerFrame = CGRect(x: 0, y: 0, width: size.width - 1, height: height - 1)
        // Change video player frame after orientation change
        playerLayer?.frame = videoPlayerFrame
        playerLayer?.layoutIfNeeded()
    }
    
    /***
     * Stop avplayer
     - remove player layer from super view
     */
    func stopPlayer(){
        
        player?.pause()
        player?.rate = 0
        player?.replaceCurrentItem(with: nil)
        playerLayer = AVPlayerLayer(player: nil)
        playerLayer?.removeFromSuperlayer()
    }
    
    /***
     * Player did become active from background or interrupt by phone call, or screen lock
     - show player controller
     - pause player
     */
    func playerDidBecomeActive() {
        
        // Show player controller
        controlViewAnimation(isShow: true)
        
        if isVideoPlaying {
            player?.play()
        }
    }
    
    
    /***
     *  Play the item
     - start auto fade animation
     - Get the item url
     - Initialize player with url
     - Update controller
     - Setup video player layer
     - Add observer for current item
     - Add periodic observer for get current play item duration and slider value
     */
    fileprivate func setupPlayerView() {
        
        // Show controller view
        self.controlViewAnimation(isShow: true)
        
        if let urlString = self.videos?[self.selectedIndex].videoURL {
            
            // Update next/previous btn
            self.upadateController()
            self.lb_videoTitle.text = self.videos?[self.selectedIndex].videoTitle
            
            if let url = URL(string: urlString) {
                
                self.player = AVPlayer(url: url)
                
                //16 x 9 is the aspect ratio of all HD videos
                let height = self.view.frame.width * 9 / 16
                let videoPlayerFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
                
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.view_videoPlayer.layer.addSublayer(self.playerLayer!)
                self.playerLayer?.frame = videoPlayerFrame
                self.player?.play()
                self.isVideoPlaying = true
                // Set pause icon to play/pause button each time start to play
                self.btn_playPause.setImage(UIImage(named: "pause"), for: .normal)
                self.view_videoPlayer.backgroundColor = .black
                
                // Adding observer for player state
                self.player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
                self.player?.addObserver(self, forKeyPath: "currentItem.playbackBufferEmpty", options: .new, context: nil)
                self.player?.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: .new, context: nil)
                
                //track player progress
                let interval = CMTime(value: 1, timescale: 2)
                self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                    
                    //When player finished to play
                    let totalDuration = self.player?.currentItem?.duration.value
                    let currentDuration = progressTime.value
                    
                    if totalDuration == currentDuration && totalDuration! > 0  && currentDuration > 0 {
                        // Finished play
                        self.playerDidFinishPlaying()
                    }
                    
                    let seconds = CMTimeGetSeconds(progressTime)
                    let secondsString = String(format: "%02d", Int(seconds.truncatingRemainder(dividingBy: 60)))
                    let minutesString = String(format: "%02d", Int(seconds / 60))
                    
                    self.lb_currentDuration.text = "\(minutesString):\(secondsString)"
                    
                    //lets move the slider thumb
                    if let duration = self.player?.currentItem?.duration {
                        let durationSeconds = CMTimeGetSeconds(duration)
                        
                        self.slider.value = Float(seconds / durationSeconds)
                    }
                })
            }
        }
    }
}

extension PlayerVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos?.count ?? 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID") as! ContentTableViewCell
        
        if isDisplayData {
            if let url = videos?[indexPath.row].thumbnailName {
                cell.iv_contentCoverImage.af_setImage(withURL: URL(string: (url))!, placeholderImage: UIImage(named: "ic_launcher-web")!,imageTransition: .crossDissolve(1.0))
            }
            
            if let title = videos![indexPath.row].videoTitle {
                
                if title == videos?[selectedIndex].videoTitle {
                    cell.lb_contentTitle.textColor = UIColor.dssTintColor()
                } else {
                    cell.lb_contentTitle.textColor = UIColor.dssTitleColor()
                }
                cell.lb_contentTitle.text = title
                cell.lb_contentSubtitle.text = "Digital Silver Screen"
                cell.lb_contentTitle.backgroundColor = UIColor.clear
                cell.lb_contentSubtitle.backgroundColor = UIColor.clear
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        stopPlayer()
        showLoading()
        tableView.reloadData()
        setupPlayerView()
    }
}

