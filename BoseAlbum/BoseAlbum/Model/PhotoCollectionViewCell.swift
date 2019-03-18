//
//  PhotoCollectionViewCell.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/17/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit

protocol PhotoCollectionViewCellDelegate: class {
    func delete(cell: PhotoCollectionViewCell)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: PhotoCollectionViewCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            deleteButtonBackgroundView.layer.cornerRadius = deleteButtonBackgroundView.bounds.width / 2.0
            deleteButtonBackgroundView.layer.masksToBounds = true
            deleteButtonBackgroundView.isHidden = true
        }
    }
    
    var isEditing: Bool = false {
        didSet {
            deleteButtonBackgroundView.isHidden = !isEditing
        }
    }
    
    @IBOutlet weak var deleteButtonBackgroundView: UIVisualEffectView!
    
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        delegate?.delete(cell: self)
    }
}
