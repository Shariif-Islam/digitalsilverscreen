//
//  Animation.swift
//  FunBox
//
//  Created by AdBox on 5/9/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class Animation  {
    
    static let sharedInstance = Animation()

    func animate(button: UIButton) {
        
        button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIViewAnimationOptions.allowUserInteraction,
                       animations: {
                        button.transform = CGAffineTransform.identity
        },
                       completion: { Void in()  }
        )
    }
    
}
