//
//  MainTableViewCell.swift
//  LacrasteCloud_Example
//
//  Created by Giovani Nícolas Bettoni on 18/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import Kingfisher

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var simpleDescription: UILabel!
    @IBOutlet weak var imageCrocodile: UIImageView!
    
    
    var post: Post?
    
    func setupData() {
        self.title.text = post?.name
        self.simpleDescription.text = post?.simpleDescription
        self.imageCrocodile.image = UIImage()
        
//        if let url = URL(string: "https://cdn-icons-png.flaticon.com/512/375/375140.png") {
//            loadImage(url: url)
//        }
        if let url = post?.image?.fileURL {
            loadImage(url: url)
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        super.selectionStyle = .none
        // Configure the view for the selected state
    }
    
    func loadImage(url: URL) {
        self.imageCrocodile.image = UIImage()
        self.imageCrocodile.kf.setImage(with: url)
        
    }

}
