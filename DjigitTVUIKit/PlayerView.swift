//
//  PlayerView.swift
//  DjigitTVUIKit
//
//  Created by Камиль Сулейманов on 14.08.2021.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
  
    let loadingView = UIView()
    let contollButtonsView = UIView()
    let activityIndicator = UIActivityIndicatorView()
    let label = UILabel()
    let playButton = UIButton(frame: CGRect(x: 10, y: 80, width: 50, height: 50))
    let pauseButton = UIButton(frame: CGRect(x: 10, y: 80, width: 50, height: 50))
    
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
          
        }
        set {
            self.backgroundColor = .black
            playerLayer.player = newValue
          
            loadingView.frame.size.height = 100
            loadingView.frame.size.width = 100
            loadingView.layer.cornerRadius = 10
            label.center = loadingView.center
            label.frame = CGRect(x: 10, y: 70, width: 80, height: 20)
            label.textAlignment = .center
            label.text = "Загрузка"
            label.textColor = .black
            activityIndicator.color = .orange
            activityIndicator.center = loadingView.center
            activityIndicator.startAnimating()
            
            loadingView.addSubview(label)
            loadingView.addSubview(activityIndicator)
          
        
            loadingView.center = self.center
            loadingView.backgroundColor = .white
            
            self.addSubview(contollButtonsView)
            self.addSubview(loadingView)
     
        }
    }
        
    private func loadButtons() {
        contollButtonsView.frame.size.height = 150
        contollButtonsView.frame.size.width = 60
        contollButtonsView.center = CGPoint(x: UIScreen.main.bounds.width - 50, y: 80)
        contollButtonsView.backgroundColor = .clear
        playButton.isHidden = true
        playButton.addTarget(self, action: #selector(playButtonAction), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pause), for: .touchUpInside)
        
        playButton.setImage(UIImage(named: "play"), for: .normal)
        pauseButton.setImage(UIImage(named: "pause"), for: .normal)
        contollButtonsView.addSubview(playButton)
        contollButtonsView.addSubview(pauseButton)
    }
    
    
    
    @objc
    func playButtonAction (_ sender: UIButton) {
    
        player?.play()
        playButton.isHidden = true
        pauseButton.isHidden = false
    }
    
    @objc
    func pause(_ sender: UIButton) {
        player?.pause()
        pauseButton.isHidden = true
        playButton.isHidden = false
    }
    
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    private var playerItemContext = 0

   
    private var playerItem: AVPlayerItem?
    
    private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                completion?(asset)
            case .failed:
                print(".failed")
             
            case .cancelled:
                print(".cancelled")
            default:
                print("default")
            }
        }
    }
    
    private func setUpPlayerItem(with asset: AVAsset) {
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
            
        DispatchQueue.main.async { [weak self] in
            self?.player = AVPlayer(playerItem: self?.playerItem!)
        }
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
            
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                player?.play()
                loadButtons()
                loadingView.removeFromSuperview()
               
            case .failed:
                print(".failed")
                label.numberOfLines = 0
                label.font = UIFont(name: "System", size: 10)
                label.frame = CGRect(x: 5, y: 5, width: 90, height: 90)
                label.text = "Канал временно не работает :("
                activityIndicator.isHidden = true
             
            case .unknown:
                print(".unknown")
            @unknown default:
                print("@unknown default")
            }
        }
    }
    
    func play(with url: URL) {
        setUpAsset(with: url) { [weak self] (asset: AVAsset) in
            self?.setUpPlayerItem(with: asset)
        }
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        print("deinit of PlayerView")
    }
}
