//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by PakWheels Test on 30/08/2023.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    static let identifier = "ConversationTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        setProfileImage()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setProfileImage(){
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = profileImage.width/2
        profileImage.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImage.image = nil
    }
    
}
