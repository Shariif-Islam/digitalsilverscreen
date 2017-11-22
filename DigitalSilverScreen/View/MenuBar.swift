//
//  MenuBar.swift
//  FunBox
//
//  Created by Machintos on 3/16/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class MenuBar: UIView {

    let collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor =  UIColor.init(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        return cv
    }()
    
    let cellID = "cellID"
    let array_icon = ["icon_video","icon_natok","icon_movie"]
    
    var homevc: HomeVC?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(MenuBarCell.self, forCellWithReuseIdentifier: cellID)
        
        addSubview(collectionView)
        addConstraintsWithFormats(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormats(format: "V:|[v0]|", views: collectionView)
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition:.top)
        
        setupHorizontalBar()
    }
    
    var horizontalBarLeftAnchorConstraint: NSLayoutConstraint?
    
    func setupHorizontalBar() {

        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = UIColor.dssTintColor()
        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalBarView)
        
        horizontalBarLeftAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftAnchorConstraint?.isActive = true
        
        horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/3).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 4).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MenuBar : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MenuBarCell

        cell.imageView.image = UIImage(named: array_icon[indexPath.row])?.withRenderingMode(.alwaysTemplate)
        cell.tintColor = UIColor.white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/3, height: frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
         homevc?.scrollToMenuIndex(indexPath.item)
    }
}


class MenuBarCell: BaseCell {
    
    let imageView : UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    override var isHighlighted: Bool {
        didSet {
            imageView.tintColor = isHighlighted ? UIColor.dssTintColor() : UIColor.dssTitleColor()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.tintColor = isSelected ? UIColor.dssTintColor() : UIColor.dssTitleColor()
        }
    }
    
    override func setupViews() {
        addSubview(imageView)
        
        addConstraintsWithFormats(format: "H:[v0(25)]", views: imageView)
        addConstraintsWithFormats(format: "V:[v0(25)]", views: imageView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
}
