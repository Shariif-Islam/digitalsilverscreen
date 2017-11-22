//
//  VideoCell.swift
//  FunBox
//
//  Created by Machintos on 3/16/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit
import AlamofireImage


class BaseCell: UICollectionViewCell {

   override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        backgroundColor = UIColor.clear
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
    }
}

class VideoCell: BaseCell {
    
    var video : Video?{
        
        didSet {
            
            if let title = video?.videoTitle {
            
                lb_tite.text = title
                lb_tite.backgroundColor = UIColor.clear
                lb_subtitle.text = "Official Video | 2017 | Digital Silver Screen"
                lb_subtitle.backgroundColor = UIColor.clear
            }

            if let imageURL = video?.thumbnailName {
                
                iv_thumbnail.backgroundColor = UIColor.clear
                iv_thumbnail.af_setImage(withURL: URL(string: (imageURL))!, placeholderImage: UIImage(named: "ic_launcher-web")!,imageTransition: .crossDissolve(1.0))
            }
        }
    }
    
    // Thumbnail imageview
    let iv_thumbnail : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 2
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1).cgColor
        imageView.backgroundColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        return imageView
    }()
    
    // view that separate the collectionview cell from each other
    let view_separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        return view
    }()

    
    let lb_tite : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 15)
        label.textColor = UIColor.dssTitleColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        return label
    }()
    
    let lb_subtitle : UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Futura", size: 11)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        return label
    }()
    
    override func setupViews() {

        // Adding view to collectionview cell videocell
        addSubview(iv_thumbnail)
        addSubview(lb_tite)
        addSubview(lb_subtitle)
        addSubview(view_separator)
        
        // Horizontal constraints
        addConstraintsWithFormats(format: "H:|-15-[v0]-15-|", views: iv_thumbnail)
        addConstraintsWithFormats(format: "H:|-15-[v0]-15-|", views: view_separator)
        addConstraintsWithFormats(format: "H:|-15-[v0]-15-|", views: lb_tite)
        addConstraintsWithFormats(format: "H:|-15-[v0]-15-|", views: lb_subtitle)
        
        // Vertical constraints
        addConstraintsWithFormats(format: "V:|-15-[v0]-10-[v1(20)]-2-[v2(20)]-15-[v3(1)]|", views: iv_thumbnail,lb_tite,lb_subtitle, view_separator)
    }
}
