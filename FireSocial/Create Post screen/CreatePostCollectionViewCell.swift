//
//  CreatePostCollectionViewCell.swift
//  FireSocial
//
//  Created by Manu on 07/02/24.
//

import UIKit

protocol CreatePostCollectionViewCellDelegate{
    func createPostCollectionViewCell(_ cell: CreatePostCollectionViewCell, didDeleteButtonPressedAt indexpath:IndexPath)
}
class CreatePostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    
    private var indexPath: IndexPath!
    var delegate: CreatePostCollectionViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func crossButtonPressed(_ sender: UIButton) {
        delegate?.createPostCollectionViewCell(self, didDeleteButtonPressedAt: indexPath)
    }
    
    
    func configureCell(image:UIImage, indexPath: IndexPath){
        self.indexPath = indexPath
        mainView.layer.cornerRadius = 15
        mainView.addShadow()
        postImageView.image = image
    }
}
