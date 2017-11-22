//
//  Extensions.swift
//  FunBox
//
//  Created by Machintos on 3/16/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
      return  UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func dssTintColor () -> UIColor {
        return UIColor.init(red: 200/255, green: 0/255, blue: 0/255, alpha: 1)
    }
    
    static func dssTitleColor () -> UIColor {
        return UIColor.init(red: 205/255, green: 205/255, blue: 205/255, alpha: 1)
    }
}


// UIView extention for adding constraints to all view
extension UIView {
    
    func addConstraintsWithFormats(format:String, views: UIView...)  {
        
        var viewsDictionary = [String:UIView]()
        
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

let imageCache = NSCache<AnyObject, AnyObject>()

class CustomImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingUrlString(_ urlString: String) {
        
        imageUrlString = urlString
        let url = URL(string: urlString)
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
            
            if error != nil {
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                let imageToCache = UIImage(data: data!)
                
                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }
                imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
            })
            
        }).resume()
    }
}

