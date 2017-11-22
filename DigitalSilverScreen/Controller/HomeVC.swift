//
//  HomeVC.swift
//  FunBox
//
//  Created by Machintos on 3/15/17.
//  Copyright © 2017 Shariif Islam. All rights reserved.
//

import UIKit

class HomeVC: UICollectionViewController {
    
    // MARK: Properties
    static let shared = HomeVC()
    static var contentType = "VIDEO"
    let videoSongCellId = "videoSongCellId"
    let natokCellId = "natokCellId"
    let movieCellId = "movienCellId"
    let titles = ["VIDEO", "NATOK", "MOVIE"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up navigation item
        let lb_navTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 44))
        lb_navTitle.text = "VIDEO"
        lb_navTitle.textColor = UIColor.dssTitleColor()
        lb_navTitle.font = UIFont(name: "Futura", size: 16)
        navigationItem.titleView = lb_navTitle
        automaticallyAdjustsScrollViewInsets = true
        
        setupCollectionView()
        setupMenuBar()
        
        // Hide navbar search/menu :ToDo
        // setupNavBar()
     
        NotificationCenter.default.addObserver(self, selector: #selector(showVideoPlayer(notification:)), name: NSNotification.Name(rawValue: "show_player_view"), object: nil)
    }

    /**
     - Show video player from notification
     */
    func showVideoPlayer(notification: NSNotification){
        
        let dict = notification.object as! NSDictionary
        let array = dict["video"] as! [Video]
        let index = dict["index"] as! Int
    
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "playerVC") as! PlayerVC
        controller.videos = array
        controller.selectedIndex = index

        self.present(controller, animated: true, completion: nil)
    }
    /**
     - Setup collectionview
     */
    func setupCollectionView() {
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        collectionView?.backgroundColor = UIColor.init(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
        collectionView?.register(VideoSongs.self, forCellWithReuseIdentifier: videoSongCellId)
        collectionView?.register(NatokCell.self, forCellWithReuseIdentifier: natokCellId)
        collectionView?.register(MovieCell.self, forCellWithReuseIdentifier: movieCellId)
        
        collectionView?.contentInset = UIEdgeInsets(top: 140, left: 0, bottom: 0, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 140, left: 0, bottom: 0, right: 0)

        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.isPagingEnabled = true
    }
    /**
     - Set title for nav bar
     */
    fileprivate func setTitleForIndex(_ index: Int) {
        
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "  \(titles[index])"
            HomeVC.contentType = "\(titles[index])"
        }
    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.homevc = self
        return mb
    }()
    
    lazy var logoView: HeaderView = {
        let hv = HeaderView()
        return hv
    }()
    
    func setupNavBar() {
    
        let searchImage = #imageLiteral(resourceName: "icon_search").withRenderingMode(.alwaysTemplate)
        let menuImage = #imageLiteral(resourceName: "icon_menu").withRenderingMode(.alwaysTemplate)
        
        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(searchAction))
        let menuBarButtonItem = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(menuAction))
        
        navigationItem.rightBarButtonItems = [menuBarButtonItem,searchBarButtonItem]
        navigationItem.rightBarButtonItems?.first?.tintColor = UIColor.white
        navigationItem.rightBarButtonItems?.last?.tintColor = UIColor.white
    }
    
    func searchAction(){
    }
    
    func menuAction(){
    }
    
    func setupMenuBar() {
        
        view.addSubview(logoView)
        view.addSubview(menuBar)
        view.addConstraintsWithFormats(format: "H:|[v0]|", views: logoView)
        view.addConstraintsWithFormats(format: "H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormats(format: "V:|-64-[v0(100)]-0-[v1(45)]", views: logoView, menuBar)
    }
    
    func scrollToMenuIndex(_ menuIndex: Int) {
        let indexPath = IndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: true)
        
        setTitleForIndex(menuIndex)
    }
}

extension HomeVC : UICollectionViewDelegateFlowLayout {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.horizontalBarLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 3
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let index = targetContentOffset.pointee.x / view.frame.width
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        
        setTitleForIndex(Int(index))
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier: String
        if indexPath.item == 1 {
            identifier = natokCellId
        } else if indexPath.item == 2 {
            identifier = movieCellId
        } else {
            identifier = videoSongCellId
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 214)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

