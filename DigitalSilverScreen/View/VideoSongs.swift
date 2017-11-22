//
//  VideoSongs.swift
//  FunBox
//
//  Created by AdBox on 4/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//


import UIKit

class VideoSongs: BaseCell {
    
    static let shared = VideoSongs()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.dataSource = self
        cv.delegate = self
        cv.indicatorStyle = .white
        return cv
    }()
    
    var videos: [Video]?
    let cellId = "cellId"

    func parseVideoData(){

        DataParge.shared.parseAPIData(DSSContentURL, parameters: DSSVideoSongParameter, type: DSSVideoSongContent, callback: { (response, status) in
            
            if status {
  
                self.videos = response
                self.collectionView.reloadData()
                
            } else {
                let when = DispatchTime.now() + 10
                DispatchQueue.main.asyncAfter(deadline: when, execute: {

                    self.parseVideoData()
                })
            }
        })
    }
 
    override func setupViews() {
        super.setupViews()
        
        parseVideoData()

        addSubview(collectionView)
        addConstraintsWithFormats(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormats(format: "V:|[v0]|", views: collectionView)

        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: cellId)
    }
}

extension VideoSongs : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos?.count ?? 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! VideoCell
        
        cell.video = videos?[indexPath.item]
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let height = (frame.width - 30) * 9 / 16
        return CGSize(width: frame.width, height: height + 84)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if videos == nil {
            return
        }
        let dic_videos = ["video": videos!,"index" :indexPath.row] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name("show_player_view"), object: dic_videos)
    }
}

