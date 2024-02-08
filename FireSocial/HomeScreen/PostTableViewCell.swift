//
//  PostTableViewCell.swift
//  FireSocial
//
//  Created by Manu on 07/02/24.
//

import UIKit
import SDWebImage
class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var post:Post?{
        didSet{
            collectionView.reloadData()
            pageControl.numberOfPages = post?.imageURLs.count ?? 0
            pageControl.isHidden = (post?.imageURLs.count ?? 0) < 2
            pageControl.currentPage = 0
            descriptionLabel.text = post?.description ?? ""
            dateLabel.text = post?.readableTime
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        // Initialization code
    }
    
    private func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CreatePostCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CreatePostCollectionViewCell")
    }
    
    func configureCell(post: Post){
        self.post = post
    }
}


extension PostTableViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        post?.imageURLs.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CreatePostCollectionViewCell", for: indexPath) as! CreatePostCollectionViewCell
        let url = URL(string: post?.imageURLs[indexPath.row] ?? "")
        cell.mainView.activityStartAnimating()
        cell.postImageView.sd_setImage(with: url) { _, _, _, _ in
            cell.mainView.activityStopAnimating()
        }
        cell.deleteButton.isHidden = true
        cell.postImageView.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let pageIndex = round(scrollView.contentOffset.x / scrollView.bounds.width)
            pageControl.currentPage = Int(pageIndex)
        }
    
}
