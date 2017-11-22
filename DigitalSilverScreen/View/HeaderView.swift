//
//  HeaderView.swift
//  FunBox
//
//  Created by AdBox on 5/8/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    
    let imageView : UIImageView = {
        let iv = UIImageView()
        let image = UIImage(named: "dss_logo")
        iv.contentMode = .scaleAspectFit
        iv.frame = CGRect(x: 15, y: 15, width: UIScreen.main.bounds.width - 35, height: 65)
        iv.backgroundColor = UIColor.clear
        iv.image = image
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.clear
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        addSubview(imageView)
    }

}
