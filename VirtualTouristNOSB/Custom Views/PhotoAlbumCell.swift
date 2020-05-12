//
//  FollowerCell.swift
//  FollowersGITHUB
//
//  Created by LALIT JAGTAP on 2/3/20.
//  Copyright © 2020 LALIT JAGTAP. All rights reserved.
//

import UIKit

class PhotoAlbumCell: UICollectionViewCell {
    
    static let reuseID = "PhotoAlbumCell"
    let albumImageView = LJImageView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(albumImageView)
        
        let padding: CGFloat = 8

        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            albumImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            albumImageView.heightAnchor.constraint(equalTo: albumImageView.widthAnchor),
        ])
    }
}
