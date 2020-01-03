

import UIKit
import AVFoundation

//MARK: -RecipeVideoViewController
class RecipeVideoViewController: UIViewController {
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    //MARK: -Properties
    @objc private var player: AVQueuePlayer?
    private var playerLayer: AVPlayerLayer?
    var titles:[String] = []
    var titleCounter: Int = 0
    private var token: NSKeyValueObservation?
    var timeObserver: Any?
    var timer: Timer?
    var recipe: Recipe!
    var recipes:[Recipe] = []
    let playerItems = [AVPlayerItem]()

    //MARK: -Functions
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startVideo(videoURL: URL(fileURLWithPath: (self.recipes[0].videoUrl)!))

        resetTimer()
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        view.addGestureRecognizer(tapgesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        player?.pause()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeLeft
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    //MARK: -User Functions
    @IBAction func playPauseTapped(_ sender: UIButton) {
        
        guard let player = player else {return}
        if !player.isPlaying {
            player.play()
            playPauseButton.setImage(UIImage(named: "orange-pause"), for: .normal)
        }
        else {
            playPauseButton.setImage(UIImage(named: "orange-play"), for: .normal)
            player.pause()
        }
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        guard let duration = player?.currentItem?.duration else {return}
        let value = Float64(progressSlider.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player?.seek(to: seekTime)
    }
    
    @IBAction func jumpForward(_ sender: UIButton) {
        
        guard let currentTime = player?.currentTime() else {return}
        let currentTimeInSecondsPlus15 = CMTimeGetSeconds(currentTime).advanced(by: 15)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsPlus15), timescale: 1)
        player?.seek(to: seekTime)
    }
    
    @IBAction func jumpBackward(_ sender: Any) {
        
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSecondsMinus15 =  CMTimeGetSeconds(currentTime).advanced(by: -15)
        let seekTime = CMTime(value: CMTimeValue(currentTimeInSecondsMinus15), timescale: 1)
        player?.seek(to: seekTime)
    }
    
    @IBAction func playNext(_ sender: UIButton) {
        
        player!.advanceToNextItem()
        titleCounter += 1
        movieTitleLabel.text = self.titles[titleCounter % self.titles.count]
    }
    
    @IBAction func playPrevious(_ sender: UIButton) {
        
        for _ in 0..<recipes.count - 1 {
            player!.advanceToNextItem()
            titleCounter += 1
        }
        
        movieTitleLabel.text = self.titles[titleCounter % self.titles.count]
    }
    
    func updateVideoPlayerState() {
        
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        progressSlider.value = Float(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            progressSlider.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            
            // Update remaining time value
            let totalTimeInSeconds = CMTimeGetSeconds(duration)
            let remainingTimeInSeconds = totalTimeInSeconds - currentTimeInSeconds
            
            let mins = remainingTimeInSeconds / 60
            let secs = remainingTimeInSeconds.truncatingRemainder(dividingBy: 60)
            let timeFormatter = NumberFormatter()
            timeFormatter.minimumIntegerDigits = 2
            timeFormatter.minimumFractionDigits = 0
            timeFormatter.roundingMode = .down
            guard let minsStr = timeFormatter.string(from: NSNumber(value: mins)),
                let secsStr = timeFormatter.string(from: NSNumber(value: secs)) else {
                    return
            }
            remainingTimeLabel.text = "\(minsStr):\(secsStr)"
        }
    }
    
    func startVideo(videoURL: URL) {
        player = AVQueuePlayer()
        playerLayer = AVPlayerLayer(player: player)

        guard let playerLayer = playerLayer else { fatalError("Error creating player layer") }
        playerLayer.frame = view.layer.bounds
        view.layer.insertSublayer(playerLayer, at: 1)
        
        addAllVideos(recipes: self.recipes)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RecipeVideoViewController.isVideoFinished), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.player?.play()
        
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { elapsedTime in self.updateVideoPlayerState()})
        
        self.token = self.player!.observe(\.currentItem) { [weak self] player, _ in
            if player.items().count == 1 {
                self?.addAllVideos(recipes: (self?.recipes)!)
            }
            
        }
        
    }
    
    func addAllVideos(recipes: [Recipe]) {
        
        for recipe in recipes {
            let asset = AVURLAsset(url: URL(fileURLWithPath: (recipe.videoUrl!)))
            let item = AVPlayerItem(asset: asset)
            
            player?.insert(item, after: player?.items().last)
            if titles.count <= 3 {
                self.titles.append(recipe.videoCaption!)
            }
        }
    }
    
    func resetTimer() {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }
    
    @objc func hideControls() {
        
        navigationController?.isNavigationBarHidden = true
        playPauseButton.isHidden = true
        progressSlider.isHidden = true
        remainingTimeLabel.isHidden = true
        forwardButton.isHidden = true
        rewindButton.isHidden = true
        movieTitleLabel.isHidden = true
        backButton.isHidden = true
        nextButton.isHidden = true
        
    }
    
    @objc func toggleControls() {

        navigationController!.isNavigationBarHidden = !navigationController!.isNavigationBarHidden
        playPauseButton.isHidden = !playPauseButton.isHidden
        progressSlider.isHidden = !progressSlider.isHidden
        remainingTimeLabel.isHidden = !remainingTimeLabel.isHidden
        forwardButton.isHidden = !forwardButton.isHidden
        rewindButton.isHidden = !rewindButton.isHidden
        movieTitleLabel.isHidden = !movieTitleLabel.isHidden
        backButton.isHidden = !backButton.isHidden
        nextButton.isHidden = !nextButton.isHidden
        resetTimer()
    }
    
    // This code checks the current state of the video and if there is a video change,
    // updates the title of the video.
    @objc func isVideoFinished() {
        titleCounter += 1
        movieTitleLabel.text = self.titles[titleCounter % self.titles.count]
    }
    
}

//MARK: AVPlayer
extension AVPlayer {
    
    // This code checks the current rate is not zero and if there’s no error.
    // If both these conditions are true, the video is currently playing.
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}


