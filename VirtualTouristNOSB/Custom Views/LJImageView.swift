//
//  GFAvatarImageView.swift
//  FollowersGITHUB
//
//  Created by LALIT JAGTAP on 2/3/20.
//  Copyright © 2020 LALIT JAGTAP. All rights reserved.
//

import UIKit

class LJImageView: UIImageView {

    let placeholderImage = UIImage(named: "placeholder-image")
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
}
