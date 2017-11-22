//
//  APIManager.swift
//  DigitalSilverScreen
//
//  Created by AdBox on 4/24/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DataParge: NSObject {
    
    static let shared = DataParge()
  
    open func parseAPIData(_ url : String, parameters : [String : String], type : String, callback:@escaping ([Video], Bool) -> ()) {
        
        var json : JSON = ""
  
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { (response) in
   
            let result = String(describing: response.result)
            
            if result == "FAILURE" {
                callback([Video](),false)
                return
            }
          
            if((response.result.value) != nil)
            {
                json = JSON(response.result.value!)
          
                if let resData = json["result"].arrayObject
                {
                    if type == DSSVideoSongContent {
                        
                        var array_videoSong = [Video]()
                        
                        for result in resData as[AnyObject]
                        {
                            let videoSong = Video()
                            
                            videoSong.videoTitle = result["album_name"] as! String
                            
                            let banner = result["album_banner"] as! String
                            let content = result["clip_video_mp4"] as! String
                            
                            videoSong.thumbnailName =  (DSSHeader + banner).replacingOccurrences(of: " ", with: "%20")
                            videoSong.videoURL = (DSSHeader + content).replacingOccurrences(of: " ", with: "%20")
                            
                            array_videoSong.append(videoSong)
                        }
                        callback(array_videoSong, true)
                    
                    }
                    else if type == DSSNatokMovieContent {
                        
                        var array_videoSong = [Video]()
                        
                        for result in resData as[AnyObject]
                        {
                            let videoSong = Video()
                            
                            videoSong.videoTitle = result["clip_name"] as! String
                            
                            let banner = result["clip_image"] as! String
                            let content = result["clip_video_mp4"] as! String
                            
                            videoSong.thumbnailName =  (DSSHeader + banner).replacingOccurrences(of: " ", with: "%20")
                            videoSong.videoURL = (DSSHeader + content).replacingOccurrences(of: " ", with: "%20")
                            
                            array_videoSong.append(videoSong)
                        }
                        callback(array_videoSong,true)
                        
                    }
                     else if type == DSSItemContent {
                        
                        var array_videoSong = [Video]()
                        
                        for result in resData as[AnyObject]
                        {
                            let videoSong = Video()
                            
                            videoSong.id = result["id"] as! String
                            videoSong.videoTitle = result["name"] as! String
                            
                            let banner = result["banner"] as! String
                            videoSong.thumbnailName =  (DSSHeader + banner).replacingOccurrences(of: " ", with: "%20")
                  
                            array_videoSong.append(videoSong)
                        }
                        callback(array_videoSong, true)
                    }
                }
            }
            else
            {
                print("🐞🐞🐞 - response data data is nill - 🐞🐞🐞")
            }
        }
    }
    
    open func checkInternetStatus(_ apiURL : String, dataType : String, callback:@escaping (Bool) -> ())
    {
        Alamofire.request(apiURL ).responseJSON{ (responseData) -> Void in
            
            let result = String(describing: responseData.result)
            
            if result == "SUCCESS" {
                callback(true)
                return
            } else {
                callback(false)
            }
        }
    }
}
