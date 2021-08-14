//
//  VideoPlayer.swift
//  DjigitTVUIKit
//
//  Created by Камиль Сулейманов on 14.08.2021.
//

import UIKit
import AVFoundation

class VideoPlayer: UIViewController {
    let contollButtonsView = UIView()
  var playerView = PlayerView()
  var videoURL = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        try! AVAudioSession.sharedInstance().setCategory(.playback, options: [])
        
        contollButtonsView.frame.size.height = 60
        contollButtonsView.frame.size.width = 60
        contollButtonsView.center = CGPoint(x: UIScreen.main.bounds.width - 50, y: 40)
        contollButtonsView.backgroundColor = .clear
        
        let closeButton = UIButton(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
     
        closeButton.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
       
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        contollButtonsView.addSubview(closeButton)
   
        playerView.frame = view.frame
        view.addSubview(playerView)
        view.addSubview(contollButtonsView)
        playVideo()
      
    }
    
    @objc
    func closePlayer(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
   
    @IBAction func swipe(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    

    
    private func playVideo() {
        guard let url = URL(string: videoURL) else { return }
        playerView.play(with: url)
    }
}

