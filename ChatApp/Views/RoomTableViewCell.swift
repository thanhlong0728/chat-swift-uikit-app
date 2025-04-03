//
//  RoomTableViewCell.swift
//  ChatApp
//
//  Created by Mac on 03/04/2025.
//

import UIKit
import SDWebImage

class RoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    static let identifier = "RoomTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = Font.listTitle
        dateLabel.font = Font.listSubTitle
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = 55 / 2
    }
    
    func configure(room: RoomModel) {
        titleLabel.text = room.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let date = dateFormatter.string(from: room.createdAt)
        dateLabel.text = "Created at \(date)"
        avatarImageView.sd_setImage(with: room.avatarURL, placeholderImage: UIImage(systemName: "person.fill"))
        selectionStyle = .none
    }

}
