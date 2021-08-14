//
//  MainVC.swift
//  DjigitTVUIKit
//
//  Created by Камиль Сулейманов on 14.08.2021.
//

import UIKit
import SDWebImage

class MainVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 351, height: 200))
    var channels: [channel] = []
    var index = -1
    private var lastContentOffset: CGFloat = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        frame = CGRect(x: 40, y: 50, width: (collectionView.bounds.width-20)/2, height: 260)
        
        super.viewDidLoad()
        activity.startAnimating()
        aboutButton.isHidden = true
        logoView.center = view.center
        logoView.image = UIImage(named: "logo")
        logoView.contentMode = .scaleAspectFit
        view.addSubview(logoView)
        
        getChannels()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout{
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 40, left: 40, bottom: 0, right: 40)
            let size = CGSize(width:(collectionView!.bounds.width-30)/2, height: 250)
            layout.itemSize = size
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let width = collectionView.frame.width
        let x = scrollView.contentOffset.x
        
            if scrollView == collectionView {
                
            
               
                
        if lastContentOffset > x {
               print("left")
//                .scaleEffect(x < screenWidth * 0.45  && x > 10 ?  1.3 : 1)
           
           }
           else if lastContentOffset < x {
             print("right")
           }
        
        lastContentOffset  = x
     
      
        
        }
    }
   
   
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ChanelCell
    
        guard !self.channels.isEmpty else {  return cell }
        cell.Image.sd_setImage(with: URL(string: channels[indexPath.row].img), completed: nil)
        
        print(cell.frame.minX)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.row
        performSegue(withIdentifier: "playVideo", sender: nil)
    }
    
    
    func getChannels() {
        guard let url = URL(string: "https://djigit-tv.ru/playlist.php") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            if let data =  try? Data(contentsOf: url){
                let decoder = JSONDecoder()
                if let jsonChannels = try? decoder.decode([channel].self, from: data){
                    
                    DispatchQueue.main.async {
                        self.channels = jsonChannels
                        print("Получил данные с API")
                        
                        if !self.channels.isEmpty {
                            self.activity.stopAnimating()
                            self.activity.isHidden = true
                            self.collectionView.reloadData()
                            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                                self.aboutButton.isHidden = false
                                self.logoView.center = CGPoint(x: 200, y: 50)
                                self.logoView.frame.size.width = 200
                            }
                            
                        }
                    }
                }
            }
        }
        .resume()
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "playVideo" else { return }
        let DVC = segue.destination as! VideoPlayer
        DVC.videoURL = channels[index].url
    }
    
    
}


