//
//  NatokCell.swift
//  FunBox
//
//  Created by AdBox on 4/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class NatokCell: VideoSongs {
    
    override func parseVideoData() {

        DataParge.shared.parseAPIData(DSSAlbumURL, parameters: DSSNatokParameter, type: DSSItemContent, callback: { (response, status) in

            if status {
                print("😄😄😄 Parse Natok Songs Data is successfull 😄😄😄")
                self.videos = response
                self.collectionView.reloadData()
            }
            else {
                let when = DispatchTime.now() + 10
                DispatchQueue.main.asyncAfter(deadline: when, execute: {
                    
                    self.parseVideoData()
                })
            }
        })
    }
}

class MovieCell: VideoSongs {
    
    override func parseVideoData() {

        DataParge.shared.parseAPIData(DSSAlbumURL, parameters: DSSMovieParameter, type: DSSItemContent, callback: { (response, status) in
        
            if status {
                print("😄😄😄 Parse MOVIE Songs Data is successfull 😄😄😄")
                self.videos = response
                self.collectionView.reloadData()
            }
            else {
                let when = DispatchTime.now() + 10
                DispatchQueue.main.asyncAfter(deadline: when, execute: {

                    self.parseVideoData()
                })
            }
        })
    }
}


